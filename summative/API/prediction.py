from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd

class CropYieldInput(BaseModel):
    Rainfall_mm: float = Field(..., ge=0, le=500, description="Rainfall in millimeters")
    Temperature_Celsius: float = Field(..., ge=-10, le=50, description="Temperature in Celsius")
    Fertilizer_Used: float = Field(..., ge=0, le=500, description="Fertilizer used in kg")
    Irrigation_Used: int = Field(..., ge=0, le=1, description="Irrigation (0=No, 1=Yes)")
    Days_to_Harvest: int = Field(..., ge=30, le=365, description="Days to harvest")
    
    # Region (one-hot encoded)
    Region_East: int = Field(0, ge=0, le=1)
    Region_North: int = Field(0, ge=0, le=1)
    Region_South: int = Field(0, ge=0, le=1)
    Region_West: int = Field(0, ge=0, le=1)
    
    # Soil Type (one-hot encoded)
    Soil_Type_Clay: int = Field(0, ge=0, le=1)
    Soil_Type_Loam: int = Field(0, ge=0, le=1)
    Soil_Type_Sandy: int = Field(0, ge=0, le=1)
    Soil_Type_Silt: int = Field(0, ge=0, le=1)
    
    # Crop Type (one-hot encoded)
    Crop_Barley: int = Field(0, ge=0, le=1)
    Crop_Cotton: int = Field(0, ge=0, le=1)
    Crop_Rice: int = Field(0, ge=0, le=1)
    Crop_Soybean: int = Field(0, ge=0, le=1)
    Crop_Wheat: int = Field(0, ge=0, le=1)
    
    # Weather Condition (one-hot encoded)
    Weather_Condition_Cloudy: int = Field(0, ge=0, le=1)
    Weather_Condition_Rainy: int = Field(0, ge=0, le=1)
    Weather_Condition_Sunny: int = Field(0, ge=0, le=1)

# Initialize FastAPI app
app = FastAPI(
    title="Crop Yield Prediction API",
    description="API for predicting crop yields",
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
    model = joblib.load('best_yield_model.pkl')
    scaler = joblib.load('scaler.pkl')
    print("Model and scaler loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None
    scaler = None

@app.get("/")
async def root():
    return {
        "message": "Crop Yield Prediction API",
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

@app.post("/predict")
async def predict_yield(input_data: CropYieldInput):
    """
    Predict crop yield based on input parameters
    """
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model not loaded properly")
    
    try:
        # Convert input to DataFrame with ALL 21 features in exact order
        input_dict = {
            'Rainfall_mm': input_data.Rainfall_mm,
            'Temperature_Celsius': input_data.Temperature_Celsius,
            'Fertilizer_Used': input_data.Fertilizer_Used,
            'Irrigation_Used': input_data.Irrigation_Used,
            'Days_to_Harvest': input_data.Days_to_Harvest,
            'Region_East': input_data.Region_East,
            'Region_North': input_data.Region_North,
            'Region_South': input_data.Region_South,
            'Region_West': input_data.Region_West,
            'Soil_Type_Clay': input_data.Soil_Type_Clay,
            'Soil_Type_Loam': input_data.Soil_Type_Loam,
            'Soil_Type_Sandy': input_data.Soil_Type_Sandy,
            'Soil_Type_Silt': input_data.Soil_Type_Silt,
            'Crop_Barley': input_data.Crop_Barley,
            'Crop_Cotton': input_data.Crop_Cotton,
            'Crop_Rice': input_data.Crop_Rice,
            'Crop_Soybean': input_data.Crop_Soybean,
            'Crop_Wheat': input_data.Crop_Wheat,
            'Weather_Condition_Cloudy': input_data.Weather_Condition_Cloudy,
            'Weather_Condition_Rainy': input_data.Weather_Condition_Rainy,
            'Weather_Condition_Sunny': input_data.Weather_Condition_Sunny
        }
        
        # Create DataFrame
        input_df = pd.DataFrame([input_dict])
        
        # Scale the features
        input_scaled = scaler.transform(input_df)
        
        # Make prediction
        prediction = model.predict(input_scaled)[0]
        
        # Determine confidence level
        if prediction < 0:
            confidence = "Low - Negative yield predicted"
            prediction = max(0, prediction)
        elif prediction > 10:
            confidence = "Medium - Very high yield predicted"
        else:
            confidence = "High - Normal yield range"
        
        return {
            "predicted_yield": round(float(prediction), 2),
            "model_confidence": confidence
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)