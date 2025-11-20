from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
from typing import Optional

# Initialize FastAPI app
app = FastAPI(
    title="Agricultural Crop Yield Prediction API",
    description="API for predicting crop yields based on environmental and agricultural factors",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the trained model and scaler
try:
    model = joblib.load('../../best_yield_model.pkl')
    scaler = joblib.load('../../scaler.pkl')
    print("Model and scaler loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None
    scaler = None

# Define input schema with Pydantic
class CropYieldInput(BaseModel):
    rainfall_mm: float = Field(..., ge=0, le=2000, description="Rainfall in millimeters (0-2000)")
    temperature_celsius: float = Field(..., ge=-10, le=50, description="Temperature in Celsius (-10 to 50)")
    fertilizer_used: int = Field(..., ge=0, le=1, description="Fertilizer used (0=No, 1=Yes)")
    irrigation_used: int = Field(..., ge=0, le=1, description="Irrigation used (0=No, 1=Yes)")
    days_to_harvest: int = Field(..., ge=30, le=365, description="Days to harvest (30-365)")
    
    # Region (one-hot encoded)
    region_north: int = Field(0, ge=0, le=1, description="Region North (0=No, 1=Yes)")
    region_south: int = Field(0, ge=0, le=1, description="Region South (0=No, 1=Yes)")
    region_west: int = Field(0, ge=0, le=1, description="Region West (0=No, 1=Yes)")
    
    # Soil Type (one-hot encoded)
    soil_type_clay: int = Field(0, ge=0, le=1, description="Clay soil (0=No, 1=Yes)")
    soil_type_loam: int = Field(0, ge=0, le=1, description="Loam soil (0=No, 1=Yes)")
    soil_type_loamy: int = Field(0, ge=0, le=1, description="Loamy soil (0=No, 1=Yes)")
    soil_type_sandy: int = Field(0, ge=0, le=1, description="Sandy soil (0=No, 1=Yes)")
    soil_type_silt: int = Field(0, ge=0, le=1, description="Silt soil (0=No, 1=Yes)")
    
    # Crop Type (one-hot encoded)
    crop_barley: int = Field(0, ge=0, le=1, description="Barley crop (0=No, 1=Yes)")
    crop_cotton: int = Field(0, ge=0, le=1, description="Cotton crop (0=No, 1=Yes)")
    crop_rice: int = Field(0, ge=0, le=1, description="Rice crop (0=No, 1=Yes)")
    crop_soybean: int = Field(0, ge=0, le=1, description="Soybean crop (0=No, 1=Yes)")
    crop_wheat: int = Field(0, ge=0, le=1, description="Wheat crop (0=No, 1=Yes)")
    
    # Weather Condition (one-hot encoded)
    weather_condition_rainy: int = Field(0, ge=0, le=1, description="Rainy weather (0=No, 1=Yes)")
    weather_condition_sunny: int = Field(0, ge=0, le=1, description="Sunny weather (0=No, 1=Yes)")

class PredictionResponse(BaseModel):
    predicted_yield: float = Field(..., description="Predicted crop yield in tons per hectare")
    model_confidence: str = Field(..., description="Model confidence level")

@app.get("/")
async def root():
    return {
        "message": "Agricultural Crop Yield Prediction API",
        "status": "active",
        "endpoints": {
            "predict": "/predict",
            "docs": "/docs",
            "health": "/health"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "scaler_loaded": scaler is not None
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_yield(input_data: CropYieldInput):
    """
    Predict crop yield based on input parameters
    """
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model not loaded properly")
    
    try:
        # Convert input to DataFrame
        input_dict = {
            'Rainfall_mm': input_data.rainfall_mm,
            'Temperature_Celsius': input_data.temperature_celsius,
            'Fertilizer_Used': input_data.fertilizer_used,
            'Irrigation_Used': input_data.irrigation_used,
            'Days_to_Harvest': input_data.days_to_harvest,
            'Region_North': input_data.region_north,
            'Region_South': input_data.region_south,
            'Region_West': input_data.region_west,
            'Soil_Type_Clay': input_data.soil_type_clay,
            'Soil_Type_Loam': input_data.soil_type_loam,
            'Soil_Type_Loamy': input_data.soil_type_loamy,
            'Soil_Type_Sandy': input_data.soil_type_sandy,
            'Soil_Type_Silt': input_data.soil_type_silt,
            'Crop_Barley': input_data.crop_barley,
            'Crop_Cotton': input_data.crop_cotton,
            'Crop_Rice': input_data.crop_rice,
            'Crop_Soybean': input_data.crop_soybean,
            'Crop_Wheat': input_data.crop_wheat,
            'Weather_Condition_Rainy': input_data.weather_condition_rainy,
            'Weather_Condition_Sunny': input_data.weather_condition_sunny
        }
        
        # Create DataFrame
        input_df = pd.DataFrame([input_dict])
        
        # Scale the features (assuming Linear Regression is the best model)
        input_scaled = scaler.transform(input_df)
        
        # Make prediction
        prediction = model.predict(input_scaled)[0]
        
        # Determine confidence level based on prediction range
        if prediction < 0:
            confidence = "Low - Negative yield predicted"
            prediction = max(0, prediction)  # Ensure non-negative yield
        elif prediction > 10:
            confidence = "Medium - Very high yield predicted"
        else:
            confidence = "High - Normal yield range"
        
        return PredictionResponse(
            predicted_yield=round(float(prediction), 2),
            model_confidence=confidence
        )
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

@app.get("/model-info")
async def get_model_info():
    """
    Get information about the loaded model
    """
    return {
        "model_type": "Agricultural Yield Prediction",
        "features": [
            "Rainfall (mm)", "Temperature (°C)", "Fertilizer Used", 
            "Irrigation Used", "Days to Harvest", "Region", 
            "Soil Type", "Crop Type", "Weather Condition"
        ],
        "target": "Crop Yield (tons per hectare)",
        "model_loaded": model is not None
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)