# prediction.py
from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import joblib
import numpy as np

# -----------------------------
# Load saved model and scaler
# -----------------------------
best_model = joblib.load('best_yield_model.pkl')
scaler = joblib.load('scaler.pkl')

# Replace with your original training feature columns
X_columns = [
    'Rainfall_mm', 'Temperature_Celsius', 'Fertilizer_Used', 'Irrigation_Used', 'Days_to_Harvest',
    'Region_East','Region_West','Soil_Type_Loamy','Soil_Type_Sandy',
    'Crop_Rice','Crop_Wheat','Weather_Condition_Rainy','Weather_Condition_Sunny'
]

# -----------------------------
# Initialize FastAPI
# -----------------------------
app = FastAPI(title="Crop Yield Prediction API")

# Enable CORS (allow all origins for simplicity)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Define input schema using Pydantic
# -----------------------------
class YieldInput(BaseModel):
    Rainfall_mm: float = Field(..., ge=0, le=500)
    Temperature_Celsius: float = Field(..., ge=-10, le=50)
    Fertilizer_Used: float = Field(..., ge=0, le=500)
    Irrigation_Used: float = Field(..., ge=0, le=1)
    Days_to_Harvest: int = Field(..., ge=30, le=365)
    
    Region_East: int = Field(..., ge=0, le=1)
    Region_West: int = Field(..., ge=0, le=1)
    
    Soil_Type_Loamy: int = Field(..., ge=0, le=1)
    Soil_Type_Sandy: int = Field(..., ge=0, le=1)
    
    Crop_Rice: int = Field(..., ge=0, le=1)
    Crop_Wheat: int = Field(..., ge=0, le=1)
    
    Weather_Condition_Rainy: int = Field(..., ge=0, le=1)
    Weather_Condition_Sunny: int = Field(..., ge=0, le=1)

# -----------------------------
# Prediction endpoint
# -----------------------------
@app.post("/predict")
def predict_yield_api(input_data: YieldInput):
    # Convert to DataFrame
    input_df = pd.DataFrame([input_data.dict()])
    
    # Add missing columns
    for col in X_columns:
        if col not in input_df.columns:
            input_df[col] = 0
    
    # Reorder columns
    input_df = input_df[X_columns]
    
    # Scale numeric features
    numeric_features = ['Rainfall_mm', 'Temperature_Celsius', 'Fertilizer_Used', 'Irrigation_Used', 'Days_to_Harvest']
    input_df[numeric_features] = scaler.transform(input_df[numeric_features])
    
    # Predict
    prediction = best_model.predict(input_df)
    return {"Predicted_Yield": float(prediction[0])}
