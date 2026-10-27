import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_planner.dart';
import 'dart:async';

class WorkoutPlannerApi {
  static const String _baseUrl = "https://ai-workout-planner-exercise-fitness-nutrition-guide.p.rapidapi.com/generateWorkoutPlan";

  static const Map<String, String> _headers = {
    "x-rapidapi-key": const String.fromEnvironment('WORKOUT_API_KEY'),
    "x-rapidapi-host": "ai-workout-planner-exercise-fitness-nutrition-guide.p.rapidapi.com",
    "Content-Type": "application/json",
  };

  /// Fetch AI Workout Plan
  Future<WorkoutPlanModel> fetchWorkoutPlan(String userGoal, String fitnessLevel) async {
    final Uri uri = Uri.parse("$_baseUrl?noqueue=1");

    final Map<String, dynamic> payload = {
      "goal": userGoal.trim(),
      "fitness_level": fitnessLevel,
      "preferences": ["Weight training", "Cardio"],
      "health_conditions": ["None"],
      "schedule": {
        "days_per_week": 4,
        "session_duration": 60,
      },
      "plan_duration_weeks": 4,
      "lang": "en"
    };

    print("Sending API Request to: $uri");

    print("Payload: ${jsonEncode(payload)}");

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );

    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData.containsKey("result")) {
        print("Workout Plan Retrieved: ${jsonEncode(jsonData)}");
        return WorkoutPlanModel.fromJson(jsonData);
      } else {
        throw Exception("Unexpected API response format");
      }
    } else {
      print("API Error: ${response.body}");
      throw Exception('Failed to fetch AI Workout Plan');
    }
  }
}
