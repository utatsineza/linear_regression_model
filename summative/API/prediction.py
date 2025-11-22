from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
from typing import Optional
from pydantic import BaseModel, Field

class CropYieldInput(BaseModel):
    Rainfall_mm: float = Field(..., ge=0, le=500, description="Rainfall in millimeters")
    Temperature_Celsius: float = Field(..., ge=-10, le=50, description="Temperature in Celsius")
    Fertilizer_Used: float = Field(..., ge=0, le=500, description="Fertilizer used in kg")
    Irrigation_Used: int = Field(..., ge=0, le=1, description="Irrigation (0=No, 1=Yes)")
    Days_to_Harvest: int = Field(..., ge=30, le=365, description="Days to harvest")
    
    # Region (one-hot encoded) - only ONE should be 1, rest 0
    Region_East: int = Field(0, ge=0, le=1)
    Region_North: int = Field(0, ge=0, le=1)
    Region_South: int = Field(0, ge=0, le=1)
    Region_West: int = Field(0, ge=0, le=1)
    
    # Soil Type (one-hot encoded) - only ONE should be 1, rest 0
    Soil_Type_Clay: int = Field(0, ge=0, le=1)
    Soil_Type_Loam: int = Field(0, ge=0, le=1)
    Soil_Type_Sandy: int = Field(0, ge=0, le=1)
    Soil_Type_Silt: int = Field(0, ge=0, le=1)
    
    # Crop Type (one-hot encoded) - only ONE should be 1, rest 0
    Crop_Barley: int = Field(0, ge=0, le=1)
    Crop_Cotton: int = Field(0, ge=0, le=1)
    Crop_Rice: int = Field(0, ge=0, le=1)
    Crop_Soybean: int = Field(0, ge=0, le=1)
    Crop_Wheat: int = Field(0, ge=0, le=1)
    
    # Weather Condition (one-hot encoded) - only ONE should be 1, rest 0
    Weather_Condition_Cloudy: int = Field(0, ge=0, le=1)
    Weather_Condition_Rainy: int = Field(0, ge=0, le=1)
    Weather_Condition_Sunny: int = Field(0, ge=0, le=1)