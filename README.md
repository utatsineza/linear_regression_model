# Agricultural Crop Yield Prediction System

## Mission
To protect, enhance and restore natural places while developing and managing infrastructure by Creating and expanding protected areas , Promoting sustainable agriculture , Educating communities , Innovations in technology, and Corporate partnerships  so as to ensure that the future generation inherit the world  where nature thrives alongside human development.

## Problem Statement
Agricultural productivity is crucial for global food security. This system predicts crop yields using machine learning to help farmers optimize resource allocation, improve planning, and maximize harvest outcomes based on weather conditions, soil types, and farming practices.

## Dataset
- **Source**: Agricultural crop yield dataset with environmental and farming factors
- **Size**: 1,000,000+ records with 10 features
- **Features**: Rainfall, temperature, fertilizer usage, irrigation, soil type, crop type, weather conditions, days to harvest
- **Target**: Crop yield in tons per hectare

## API Endpoint
🌐 **Live API/swagger UI**: https://linear-regression-model-q8oj.onrender.com/docs

## Project Structure
```
linear_regression_model/
├── summative/
│   ├── linear_regression/
│   │   └── multivariate.ipynb
│   ├── API/
│   │   ├── prediction.py
│   │   └── requirements.txt
│   └── FlutterApp/
│       ├── lib/
│       │   └── main.dart
│       └── pubspec.yaml
├── agriculture_crop_yield.csv
├── best_yield_model.pkl
├── scaler.pkl
└── README.md
```

## Model Performance
- **Linear Regression**: R² Score, MSE
- **Decision Tree**: R² Score, MSE  
- **Random Forest**: R² Score, MSE
- **Best Model**: [Will be determined after training]

## How to Run

### 1. Jupyter Notebook
```bash
cd linear_regression_model/summative/linear_regression
jupyter notebook multivariate.ipynb
```

### 2. API Server
```bash
cd linear_regression_model/summative/API
pip install -r requirements.txt
uvicorn prediction:app --host 0.0.0.0 --port 8000
```

### 3. Flutter Mobile App
```bash
cd linear_regression_model/summative/FlutterApp
flutter pub get
flutter run
```

## Video Demo
📹 **YouTube Demo**: https://youtu.be/RLxt2o5mVuc

## Features
- ✅ Linear Regression, Decision Tree, and Random Forest models
- ✅ Data visualization and correlation analysis
- ✅ Feature engineering and standardization
- ✅ FastAPI with CORS and Pydantic validation
- ✅ Flutter mobile app with intuitive UI
- ✅ Real-time predictions via API
- ✅ Input validation and error handling

## Technologies Used
- **Machine Learning**: scikit-learn, pandas, numpy
- **API**: FastAPI, uvicorn, pydantic
- **Mobile**: Flutter, Dart
- **Visualization**: matplotlib, seaborn
- **Deployment**: Render