import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

column_names = [
    'loan_amnt', 'loan_int_rate', 'loan_percent_income',
    'emp_length_was_missing', 'interest_rate_was_missing',
    'person_age', 'person_income', 'person_home_ownership',
    'emp_length', 'cred_hist_length', 'default_on_file',
    'loan_intent', 'loan_grade', 'loan_status'
]
df = pd.read_csv('loans_clean.csv', header=None, names=column_names)

X = df.drop('loan_status', axis=1)
y = df['loan_status']

numeric_features = [
    'loan_amnt', 'loan_int_rate', 'loan_percent_income',
    'emp_length_was_missing', 'interest_rate_was_missing',
    'person_age', 'person_income', 'emp_length', 'cred_hist_length'
]
categorical_features = ['person_home_ownership', 'default_on_file', 'loan_intent', 'loan_grade']


preprocessor = ColumnTransformer(
    transformers=[
        ('num', StandardScaler(), numeric_features),
        ('cat', OneHotEncoder(drop='first', handle_unknown='ignore'), categorical_features)
    ]
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

lr_model = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', LogisticRegression(max_iter=1000, random_state=42))
])
lr_model.fit(X_train, y_train)
y_pred = lr_model.predict(X_test)

print("=== Logistic Regression Results ===")
print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
print("\nConfusion Matrix:\n", confusion_matrix(y_test, y_pred))
print("\nClassification Report:\n", classification_report(y_test, y_pred))