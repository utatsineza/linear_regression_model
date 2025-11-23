# Agricultural Crop Yield Prediction Mobile App

A Flutter mobile application for predicting crop yields based on environmental and agricultural factors.

## Live Demo
🌐 **API Endpoint**: https://linear-regression-model-q8oj.onrender.com/docss
📹 **Video Demo**:https://youtu.be/_uu-8B-JOBQ

## Features
- Input agricultural parameters (rainfall, temperature, fertilizer usage, etc.)
- Real-time crop yield predictions via API
- User-friendly interface with input validation
- Support for multiple crop types, soil types, and weather conditions

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- API server running (see ../API/README.md)

### Installation
```bash
flutter pub get
flutter run
```

### Configuration
Update the API endpoint in `lib/main.dart` to match your deployed API URL.

## Input Parameters
- Rainfall (mm)
- Temperature (°C)
- Fertilizer usage (Yes/No)
- Irrigation usage (Yes/No)
- Days to harvest
- Region (North/South/West/East)
- Soil type (Clay/Loam/Loamy/Sandy/Silt)
- Crop type (Barley/Cotton/Rice/Soybean/Wheat)
- Weather condition (Rainy/Sunny/Cloudy)
