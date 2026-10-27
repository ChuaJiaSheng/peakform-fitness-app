import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/workout_planner.dart';
import '../widgets/navigation_bar.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import 'add_workout_planner_screen.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  List<WorkoutPlanModel> _workoutPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlans();
  }

  Future<void> _fetchWorkoutPlans() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('workoutPlans')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      _workoutPlans = snapshot.docs.map((doc) {
        return WorkoutPlanModel(
          goal: doc['goal'],
          fitnessLevel: doc['fitnessLevel'],
          totalWeeks: doc['totalWeeks'],
          daysPerWeek: doc['daysPerWeek'],
          sessionDuration: doc['sessionDuration'],
          workoutDays: (doc['workoutDays'] as List<dynamic>).map((day) {
            return WorkoutDay(
              day: day['day'],
              exercises: (day['exercises'] as List<dynamic>).map((exercise) {
                return Exercise(
                  name: exercise['name'],
                  duration: exercise['duration'],
                  repetitions: exercise['repetitions'],
                  sets: exercise['sets'],
                  equipment: exercise['equipment'],
                );
              }).toList(),
            );
          }).toList(),
          seoTitle: '',
          seoContent: '',
        );
      }).toList();
      _isLoading = false;
    });
  }

  void _navigateToAddWorkoutPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWorkoutPlannerScreen()),
    );
    _fetchWorkoutPlans();
  }

  Future<void> _deleteWorkoutPlan(String docId, int index) async {
    if (docId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('workoutPlans').doc(docId).delete();
    }
    setState(() {
      _workoutPlans.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('Workout Planner', style: AppTextStyles.headline),
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _workoutPlans.isEmpty
          ? const Center(
        child: Text(
          'No workout plans added yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workoutPlans.length,
        itemBuilder: (context, index) {
          final plan = _workoutPlans[index];
          return _buildWorkoutCard(plan, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWorkoutPlan,
        child: const Icon(Icons.add, size: 28), // Plus Sign
        elevation: 4, // Adds shadow effect for a modern look
        backgroundColor: AppTheme.textBlack,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MyBottomNavigationBar(selectedIndexNavBar: 3),
    );
  }

  Widget _buildWorkoutCard(WorkoutPlanModel plan, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                plan.goal,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Level: ${plan.fitnessLevel}", style: AppTextStyles.body),
                Text("${plan.totalWeeks} weeks • ${plan.daysPerWeek} days/week", style: AppTextStyles.caption),
                const SizedBox(height: 12),
                _buildWorkoutDays(plan.workoutDays),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Session Duration: ${plan.sessionDuration} mins", style: AppTextStyles.caption),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteWorkoutPlan(plan.goal, index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutDays(List<WorkoutDay> workoutDays) {
    return Column(
      children: workoutDays.map((day) {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppTheme.primaryYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.day, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...day.exercises.map((exercise) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${exercise.name} - ${exercise.sets} sets x ${exercise.repetitions} reps",
                        style: AppTextStyles.caption,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
