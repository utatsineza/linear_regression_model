import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CropYieldApp());
}

class CropYieldApp extends StatelessWidget {
  const CropYieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Predictor',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _daysToHarvestController = TextEditingController();
  
  // Dropdown values
  bool _fertilizerUsed = false;
  bool _irrigationUsed = false;
  String _region = 'East';
  String _soilType = 'Clay';
  String _cropType = 'Rice';
  String _weatherCondition = 'Cloudy';
  
  String _predictionResult = '';
  bool _isLoading = false;
  
  // API endpoint - Replace with your deployed API URL
  final String apiUrl = 'https://your-api-url.com/predict';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Yield Predictor'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Agricultural Parameters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Rainfall input
              TextFormField(
                controller: _rainfallController,
                decoration: const InputDecoration(
                  labelText: 'Rainfall (mm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rainfall amount';
                  }
                  final rainfall = double.tryParse(value);
                  if (rainfall == null || rainfall < 0 || rainfall > 2000) {
                    return 'Please enter a valid rainfall (0-2000 mm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Temperature input
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.thermostat),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter temperature';
                  }
                  final temp = double.tryParse(value);
                  if (temp == null || temp < -10 || temp > 50) {
                    return 'Please enter a valid temperature (-10 to 50°C)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Days to harvest input
              TextFormField(
                controller: _daysToHarvestController,
                decoration: const InputDecoration(
                  labelText: 'Days to Harvest',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter days to harvest';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 30 || days > 365) {
                    return 'Please enter valid days (30-365)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Fertilizer switch
              SwitchListTile(
                title: const Text('Fertilizer Used'),
                value: _fertilizerUsed,
                onChanged: (value) {
                  setState(() {
                    _fertilizerUsed = value;
                  });
                },
                secondary: const Icon(Icons.eco),
              ),
              
              // Irrigation switch
              SwitchListTile(
                title: const Text('Irrigation Used'),
                value: _irrigationUsed,
                onChanged: (value) {
                  setState(() {
                    _irrigationUsed = value;
                  });
                },
                secondary: const Icon(Icons.water),
              ),
              const SizedBox(height: 16),
              
              // Region dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Region',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                value: _region,
                items: ['East', 'North', 'South', 'West']
                    .map((region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _region = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Soil type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Soil Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terrain),
                ),
                value: _soilType,
                items: ['Clay', 'Loam', 'Loamy', 'Sandy', 'Silt']
                    .map((soil) => DropdownMenuItem(
                          value: soil,
                          child: Text(soil),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _soilType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Crop type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Crop Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grass),
                ),
                value: _cropType,
                items: ['Barley', 'Cotton', 'Rice', 'Soybean', 'Wheat']
                    .map((crop) => DropdownMenuItem(
                          value: crop,
                          child: Text(crop),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cropType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Weather condition dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Weather Condition',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wb_sunny),
                ),
                value: _weatherCondition,
                items: ['Cloudy', 'Rainy', 'Sunny']
                    .map((weather) => DropdownMenuItem(
                          value: weather,
                          child: Text(weather),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _weatherCondition = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Predict button
              ElevatedButton(
                onPressed: _isLoading ? null : _predictYield,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Predict Yield'),
              ),
              const SizedBox(height: 24),
              
              // Result display
              if (_predictionResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Prediction Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _predictionResult,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _predictYield() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = '';
    });

    try {
      // Prepare the request body
      final requestBody = {
        'rainfall_mm': double.parse(_rainfallController.text),
        'temperature_celsius': double.parse(_temperatureController.text),
        'fertilizer_used': _fertilizerUsed ? 1 : 0,
        'irrigation_used': _irrigationUsed ? 1 : 0,
        'days_to_harvest': int.parse(_daysToHarvestController.text),
        
        // Region encoding (one-hot)
        'region_north': _region == 'North' ? 1 : 0,
        'region_south': _region == 'South' ? 1 : 0,
        'region_west': _region == 'West' ? 1 : 0,
        
        // Soil type encoding (one-hot)
        'soil_type_clay': _soilType == 'Clay' ? 1 : 0,
        'soil_type_loam': _soilType == 'Loam' ? 1 : 0,
        'soil_type_loamy': _soilType == 'Loamy' ? 1 : 0,
        'soil_type_sandy': _soilType == 'Sandy' ? 1 : 0,
        'soil_type_silt': _soilType == 'Silt' ? 1 : 0,
        
        // Crop type encoding (one-hot)
        'crop_barley': _cropType == 'Barley' ? 1 : 0,
        'crop_cotton': _cropType == 'Cotton' ? 1 : 0,
        'crop_rice': _cropType == 'Rice' ? 1 : 0,
        'crop_soybean': _cropType == 'Soybean' ? 1 : 0,
        'crop_wheat': _cropType == 'Wheat' ? 1 : 0,
        
        // Weather condition encoding (one-hot)
        'weather_condition_rainy': _weatherCondition == 'Rainy' ? 1 : 0,
        'weather_condition_sunny': _weatherCondition == 'Sunny' ? 1 : 0,
      };

      // Make API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _predictionResult = 
              'Predicted Yield: ${responseData['predicted_yield']} tons/hectare\n'
              'Confidence: ${responseData['model_confidence']}';
        });
      } else {
        setState(() {
          _predictionResult = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Network Error: Please check your connection and API URL.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _rainfallController.dispose();
    _temperatureController.dispose();
    _daysToHarvestController.dispose();
    super.dispose();
  }
}