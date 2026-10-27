import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';
import '../theme/text_styles.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final List<Map<String, dynamic>> _exercises = [
    {"name": "Running", "icon": Icons.directions_run, "type": "Cardio"},
    {"name": "Swimming", "icon": Icons.pool, "type": "Endurance"},
    {"name": "Hiking", "icon": Icons.terrain, "type": "Strength"},
    {"name": "Cycling", "icon": Icons.pedal_bike, "type": "Cardio"},
  ];

  String? _selectedExercise;
  int _selectedDuration = 15;
  bool _isLoading = false;

  Future<void> _addExercise() async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int burnedCalories = _selectedDuration * 7; // Simple calorie calculation

    final newExercise = Exercise(
      activity: _selectedExercise!,
      duration: _selectedDuration,
      burnedCalories: burnedCalories,
    );

    // Save to Firestore
    await FirebaseFirestore.instance.collection('exercises').add({
      'activity': newExercise.activity,
      'duration': newExercise.duration,
      'burnedCalories': newExercise.burnedCalories,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context, newExercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Exercise', style: AppTextStyles.headline),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Choose an Exercise",
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: 16),

            // Exercise Selection
            SizedBox(
              height: 120,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExercise = exercise["name"];
                        });
                      },
                      child: ExerciseCard(
                        name: exercise["name"],
                        icon: exercise["icon"],
                        type: exercise["type"],
                        isSelected: _selectedExercise == exercise["name"],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Duration Selection
            const Text("Select Duration", style: AppTextStyles.title),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [45, 60, 120, 240].map((time) {
                return ChoiceChip(
                  label: Text(
                    time == 45
                        ? "45 mins"
                        : "${time ~/ 60} hr${time >= 120 ? 's' : ''}",
                    style: TextStyle(
                      color: _selectedDuration == time
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _selectedDuration == time,
                  selectedColor: Colors.black,
                  backgroundColor: Colors.grey[300],
                  onSelected: (selected) {
                    setState(() {
                      _selectedDuration = time;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Add Exercise Button
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                : Center(
                    child: ElevatedButton(
                      onPressed: _addExercise,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.black,
                      ),
                      child: const Text('Add Exercise',
                          style: AppTextStyles.button),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Custom Exercise Card UI
class ExerciseCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String type;
  final bool isSelected;

  const ExerciseCard({
    Key? key,
    required this.name,
    required this.icon,
    required this.type,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: isSelected ? Colors.white : Colors.black),
          const SizedBox(height: 8),
          Text(name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(type,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
