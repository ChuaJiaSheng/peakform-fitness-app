import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_planner.dart';
import '../utilities/workout_planner_api.dart';

class AddWorkoutPlannerScreen extends StatefulWidget {
  const AddWorkoutPlannerScreen({Key? key}) : super(key: key);

  @override
  State<AddWorkoutPlannerScreen> createState() => _AddWorkoutPlannerScreenState();
}

class _AddWorkoutPlannerScreenState extends State<AddWorkoutPlannerScreen> {
  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'Endurance', 'Flexibility'];
  final List<String> _fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];

  String? _selectedGoal;
  String? _selectedFitnessLevel;
  bool _isLoading = false;
  String _errorMessage = '';

  /// Generate workout plan using API and save to Firebase
  Future<void> _generateWorkoutPlan() async {
    if (_selectedGoal == null || _selectedFitnessLevel == null) {
      setState(() {
        _errorMessage = 'Please select a goal and fitness level.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      WorkoutPlanModel workoutPlan = await WorkoutPlannerApi().fetchWorkoutPlan(
        _selectedGoal!,
        _selectedFitnessLevel!,
      );

      await _saveWorkoutPlanToFirebase(workoutPlan);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating workout plan. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Save generated workout plan to Firebase
  Future<void> _saveWorkoutPlanToFirebase(WorkoutPlanModel workoutPlan) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('workoutPlans').add({
      'userId': userId,
      'goal': workoutPlan.goal,
      'fitnessLevel': workoutPlan.fitnessLevel,
      'totalWeeks': workoutPlan.totalWeeks,
      'daysPerWeek': workoutPlan.daysPerWeek,
      'sessionDuration': workoutPlan.sessionDuration,
      'workoutDays': workoutPlan.workoutDays.map((day) => {
        'day': day.day,
        'exercises': day.exercises.map((exercise) => {
          'name': exercise.name,
          'duration': exercise.duration,
          'repetitions': exercise.repetitions,
          'sets': exercise.sets,
          'equipment': exercise.equipment,
        }).toList(),
      }).toList(),
    });

    print("Workout plan saved successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Your Goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              items: _goals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
              onChanged: (value) => setState(() => _selectedGoal = value),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 16),
            const Text("Select Your Fitness Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFitnessLevel,
              items: _fitnessLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (value) => setState(() => _selectedFitnessLevel = value),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 16),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _generateWorkoutPlan,
                child: const Text('Generate Workout Plan'),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
