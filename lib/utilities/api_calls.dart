import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bmi.dart';
import '../models/fitness_user.dart';

class ApiCalls {
  Future<Bmi> fetchBmi(FitnessUser user) async {
    String baseURL = 'https://fitness-api.p.rapidapi.com/fitness';

    Map<String, String> requestHeaders = {
      'X-RapidAPI-Host': 'fitness-api.p.rapidapi.com',
      'X-RapidAPI-Key': const String.fromEnvironment('FITNESS_API_KEY'),  // Replace with actual API Key
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> payload = {
      'height': user.height,
      'weight': user.weight,
      'age': user.age,
      'gender': user.gender.toUpperCase(),
    };

    print("Sending API Request to: $baseURL");
    print("Payload: $payload");

    final response = await http.post(
      Uri.parse(baseURL),
      headers: requestHeaders,
      body: jsonEncode(payload),
    );

    print("API Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("API Response: $responseData");

      return Bmi.fromJson(responseData);
    } else {
      final errorMessage = response.body;
      print("API Error: $errorMessage");
      throw Exception('Failed to load BMI data: ${response.statusCode}');
    }
  }
}
