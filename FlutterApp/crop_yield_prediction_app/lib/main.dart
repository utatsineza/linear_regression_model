import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CropYieldApp());
}

class CropYieldApp extends StatelessWidget {
  const CropYieldApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final String apiUrl = 'https://linear-regression-model-ty1c.onrender.com/predict';
  
  // Controllers for text fields
  final TextEditingController rainfallController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController fertilizerController = TextEditingController();
  final TextEditingController daysToHarvestController = TextEditingController();
  
  // Dropdown values
  String? selectedRegion;
  String? selectedSoilType;
  String? selectedCropType;
  String? selectedWeatherCondition;
  bool useIrrigation = false;
  
  String predictionResult = '';
  bool isLoading = false;
  Color resultColor = Colors.black;

  @override
  void dispose() {
    rainfallController.dispose();
    temperatureController.dispose();
    fertilizerController.dispose();
    daysToHarvestController.dispose();
    super.dispose();
  }

  Future<void> makePrediction() async {
    if (rainfallController.text.isEmpty ||
        temperatureController.text.isEmpty ||
        fertilizerController.text.isEmpty ||
        daysToHarvestController.text.isEmpty ||
        selectedRegion == null ||
        selectedSoilType == null ||
        selectedCropType == null ||
        selectedWeatherCondition == null) {
      setState(() {
        predictionResult = 'Error: Please fill in all fields';
        resultColor = Colors.red;
      });
      return;
    }

    setState(() {
      isLoading = true;
      predictionResult = '';
    });

    try {
      // Prepare request with ALL 21 features in exact order
      final Map<String, dynamic> requestBody = {
        'Rainfall_mm': double.parse(rainfallController.text),
        'Temperature_Celsius': double.parse(temperatureController.text),
        'Fertilizer_Used': double.parse(fertilizerController.text),
        'Irrigation_Used': useIrrigation ? 1 : 0,
        'Days_to_Harvest': int.parse(daysToHarvestController.text),
        
        // Region (only ONE can be 1)
        'Region_East': selectedRegion == 'East' ? 1 : 0,
        'Region_North': selectedRegion == 'North' ? 1 : 0,
        'Region_South': selectedRegion == 'South' ? 1 : 0,
        'Region_West': selectedRegion == 'West' ? 1 : 0,
        
        // Soil Type (only ONE can be 1)
        'Soil_Type_Clay': selectedSoilType == 'Clay' ? 1 : 0,
        'Soil_Type_Loam': selectedSoilType == 'Loam' ? 1 : 0,
        'Soil_Type_Sandy': selectedSoilType == 'Sandy' ? 1 : 0,
        'Soil_Type_Silt': selectedSoilType == 'Silt' ? 1 : 0,
        
        // Crop Type (only ONE can be 1)
        'Crop_Barley': selectedCropType == 'Barley' ? 1 : 0,
        'Crop_Cotton': selectedCropType == 'Cotton' ? 1 : 0,
        'Crop_Rice': selectedCropType == 'Rice' ? 1 : 0,
        'Crop_Soybean': selectedCropType == 'Soybean' ? 1 : 0,
        'Crop_Wheat': selectedCropType == 'Wheat' ? 1 : 0,
        
        // Weather Condition (only ONE can be 1)
        'Weather_Condition_Cloudy': selectedWeatherCondition == 'Cloudy' ? 1 : 0,
        'Weather_Condition_Rainy': selectedWeatherCondition == 'Rainy' ? 1 : 0,
        'Weather_Condition_Sunny': selectedWeatherCondition == 'Sunny' ? 1 : 0,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictionResult = 
              'Predicted Yield: ${data['predicted_yield']} tons/hectare\n'
              'Confidence: ${data['model_confidence']}';
          resultColor = Colors.green.shade700;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          predictionResult = 'Error: ${error['detail']}';
          resultColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = 'Error: $e';
        resultColor = Colors.red;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Yield Predictor'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.agriculture, size: 48, color: Colors.green.shade700),
                      const SizedBox(height: 8),
                      Text(
                        'Agricultural Yield Prediction',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle('Environmental Conditions'),
              _buildTextField(
                controller: rainfallController,
                label: 'Rainfall (mm)',
                hint: '0 - 500',
                icon: Icons.water_drop,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: temperatureController,
                label: 'Temperature (°C)',
                hint: '-10 to 50',
                icon: Icons.thermostat,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: selectedWeatherCondition,
                label: 'Weather Condition',
                icon: Icons.wb_sunny,
                items: ['Sunny', 'Rainy', 'Cloudy'],
                onChanged: (value) => setState(() => selectedWeatherCondition = value),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle('Agricultural Inputs'),
              _buildDropdown(
                value: selectedCropType,
                label: 'Crop Type',
                icon: Icons.grass,
                items: ['Wheat', 'Rice', 'Cotton', 'Barley', 'Soybean'],
                onChanged: (value) => setState(() => selectedCropType = value),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: selectedSoilType,
                label: 'Soil Type',
                icon: Icons.terrain,
                items: ['Clay', 'Sandy', 'Loam', 'Silt'],
                onChanged: (value) => setState(() => selectedSoilType = value),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: selectedRegion,
                label: 'Region',
                icon: Icons.location_on,
                items: ['North', 'South', 'East', 'West'],
                onChanged: (value) => setState(() => selectedRegion = value),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: daysToHarvestController,
                label: 'Days to Harvest',
                hint: '30 - 365',
                icon: Icons.calendar_today,
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle('Farming Practices'),
              _buildTextField(
                controller: fertilizerController,
                label: 'Fertilizer Used (kg)',
                hint: '0 - 500',
                icon: Icons.science,
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Use Irrigation',
                icon: Icons.water,
                value: useIrrigation,
                onChanged: (value) => setState(() => useIrrigation = value),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: isLoading ? null : makePrediction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Predict',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              if (predictionResult.isNotEmpty)
                Card(
                  elevation: 4,
                  color: resultColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: resultColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          resultColor == Colors.red ? Icons.error : Icons.check_circle,
                          size: 48,
                          color: resultColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          predictionResult,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: resultColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        secondary: Icon(icon, color: Colors.green.shade700),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.green.shade700,
      ),
    );
  }
}