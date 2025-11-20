# Crop Yield Predictor Flutter App

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

### Installation Steps

1. **Navigate to the Flutter app directory:**
   ```bash
   cd linear_regression_model/summative/FlutterApp
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API URL:**
   - Open `lib/main.dart`
   - Find the line: `final String apiUrl = 'https://your-api-url.com/predict';`
   - Replace with your deployed API URL

4. **Run the app:**
   ```bash
   flutter run
   ```

## App Features

- **Input Fields**: 8 input fields for agricultural parameters
- **Validation**: Input validation with proper error messages
- **Dropdowns**: Easy selection for categorical variables
- **Switches**: Toggle switches for boolean inputs
- **Prediction**: Real-time API calls for yield prediction
- **Error Handling**: Proper error messages for network issues

## Input Parameters

1. **Rainfall (mm)**: 0-2000
2. **Temperature (°C)**: -10 to 50
3. **Days to Harvest**: 30-365
4. **Fertilizer Used**: Yes/No toggle
5. **Irrigation Used**: Yes/No toggle
6. **Region**: East/North/South/West dropdown
7. **Soil Type**: Clay/Loam/Loamy/Sandy/Silt dropdown
8. **Crop Type**: Barley/Cotton/Rice/Soybean/Wheat dropdown
9. **Weather Condition**: Cloudy/Rainy/Sunny dropdown

## API Integration

The app makes HTTP POST requests to the prediction API with proper JSON formatting and error handling. The API response includes:
- Predicted yield in tons per hectare
- Model confidence level

## Troubleshooting

- **Network Error**: Check internet connection and API URL
- **Validation Errors**: Ensure all inputs are within valid ranges
- **Build Issues**: Run `flutter clean` then `flutter pub get`