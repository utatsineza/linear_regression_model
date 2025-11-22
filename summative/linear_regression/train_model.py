import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import matplotlib.pyplot as plt

# Load and prepare data
print("Loading data...")
df = pd.read_csv('agriculture_crop_yield.csv')

# Convert boolean columns to numeric
df['Fertilizer_Used'] = df['Fertilizer_Used'].astype(int)
df['Irrigation_Used'] = df['Irrigation_Used'].astype(int)

# Create dummy variables
df_encoded = pd.get_dummies(df, columns=['Region', 'Soil_Type', 'Crop', 'Weather_Condition'], drop_first=True)

# Prepare features and target
X = df_encoded.drop('Yield_tons_per_hectare', axis=1)
y = df_encoded['Yield_tons_per_hectare']

print(f"Dataset shape: {X.shape}")
print(f"Features: {list(X.columns)}")

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train models
models = {
    'Linear Regression': LinearRegression(),
    'Decision Tree': DecisionTreeRegressor(random_state=42, max_depth=10),
    'Random Forest': RandomForestRegressor(n_estimators=100, random_state=42, max_depth=10)
}

results = {}
best_model = None
best_score = -np.inf
best_name = ""

print("\nTraining models...")
for name, model in models.items():
    print(f"Training {name}...")
    
    if name == 'Linear Regression':
        model.fit(X_train_scaled, y_train)
        y_pred = model.predict(X_test_scaled)
    else:
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
    
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    results[name] = {'mse': mse, 'r2': r2}
    
    print(f"  MSE: {mse:.4f}")
    print(f"  R²: {r2:.4f}")
    
    if r2 > best_score:
        best_score = r2
        best_model = model
        best_name = name

print(f"\nBest model: {best_name} (R² = {best_score:.4f})")

# Save best model and scaler
joblib.dump(best_model, 'best_yield_model.pkl')
joblib.dump(scaler, 'scaler.pkl')
joblib.dump(list(X.columns), 'feature_names.pkl')

print("Model files saved successfully!")
print("- best_yield_model.pkl")
print("- scaler.pkl") 
print("- feature_names.pkl")

# Create a simple visualization
plt.figure(figsize=(10, 6))
model_names = list(results.keys())
r2_scores = [results[name]['r2'] for name in model_names]
mse_scores = [results[name]['mse'] for name in model_names]

plt.subplot(1, 2, 1)
plt.bar(model_names, r2_scores, color=['blue', 'green', 'orange'])
plt.title('Model R² Scores')
plt.ylabel('R² Score')
plt.xticks(rotation=45)

plt.subplot(1, 2, 2)
plt.bar(model_names, mse_scores, color=['blue', 'green', 'orange'])
plt.title('Model MSE Scores')
plt.ylabel('MSE')
plt.xticks(rotation=45)

plt.tight_layout()
plt.savefig('model_comparison.png', dpi=150, bbox_inches='tight')
plt.show()

print("\nModel comparison plot saved as 'model_comparison.png'")