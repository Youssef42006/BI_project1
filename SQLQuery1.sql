USE BankingFinanceDB;

CREATE TABLE Dim_Customer (
    Customer_ID INT IDENTITY(1,1) PRIMARY KEY,
    person_age INT,
    Age_Group NVARCHAR(50),
    person_income BIGINT,
    Income_Category NVARCHAR(50),
    person_home_ownership VARCHAR(50),
    emp_length REAL,
    cred_hist_length INT,
    default_on_file VARCHAR(50)
);

CREATE TABLE Dim_Loan_Details (
    Loan_Detail_ID INT IDENTITY(1,1) PRIMARY KEY,
    loan_intent VARCHAR(50),
    loan_grade VARCHAR(50),
    Loan_Amount_Category NVARCHAR(50)
);

CREATE TABLE Fact_Loans (
    application_id INT PRIMARY KEY,
    Customer_ID INT FOREIGN KEY REFERENCES Dim_Customer(Customer_ID),
    Loan_Detail_ID INT FOREIGN KEY REFERENCES Dim_Loan_Details(Loan_Detail_ID),
    loan_amnt INT,
    loan_int_rate REAL,
    loan_percent_income REAL,
    loan_status INT,
    emp_length_was_missing INT,
    interest_rate_was_missing INT
);

INSERT INTO Dim_Customer (
    person_age, Age_Group, person_income, Income_Category,
    person_home_ownership, emp_length, cred_hist_length, default_on_file
)
SELECT DISTINCT
    person_age_converted,
    Age_Group,
    person_income_converted,
    Income_Category,
    person_home_ownership,
    emp_length_clean_converted,
    cb_person_cred_hist_length_converted,
    cb_person_default_on_file
FROM [OLE DB Destination];

INSERT INTO Dim_Loan_Details (
    loan_intent, loan_grade, Loan_Amount_Category
)
SELECT DISTINCT
    loan_intent,
    loan_grade,
    Loan_Amount_Category
FROM [OLE DB Destination];

INSERT INTO Fact_Loans (
    application_id, Customer_ID, Loan_Detail_ID,
    loan_amnt, loan_int_rate, loan_percent_income, loan_status,
    emp_length_was_missing, interest_rate_was_missing
)
SELECT
    src.application_id_converted,
    c.Customer_ID,
    l.Loan_Detail_ID,
    src.loan_amnt_converted,
    src.interest_rate_clean_converted,
    src.loan_percent_income_converted,
    src.loan_status_converted,
    src.emp_length_was_missing,
    src.interest_rate_was_missing
FROM [OLE DB Destination] src
INNER JOIN Dim_Customer c
    ON ISNULL(src.person_age_converted, -1) = ISNULL(c.person_age, -1)
    AND ISNULL(src.person_income_converted, -1) = ISNULL(c.person_income, -1)
    AND ISNULL(src.person_home_ownership, '') = ISNULL(c.person_home_ownership, '')
    AND ISNULL(src.emp_length_clean_converted, -1) = ISNULL(c.emp_length, -1)
    AND ISNULL(src.cb_person_cred_hist_length_converted, -1) = ISNULL(c.cred_hist_length, -1)
    AND ISNULL(src.cb_person_default_on_file, '') = ISNULL(c.default_on_file, '')
INNER JOIN Dim_Loan_Details l
    ON ISNULL(src.loan_intent, '') = ISNULL(l.loan_intent, '')
    AND ISNULL(src.loan_grade, '') = ISNULL(l.loan_grade, '')
    AND ISNULL(src.Loan_Amount_Category, '') = ISNULL(l.Loan_Amount_Category, '');
