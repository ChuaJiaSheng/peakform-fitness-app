import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';
import '../theme/text_styles.dart';
import '../widgets/navigation_bar.dart';
import 'add_exercise_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  /// Fetch Exercises from Firestore
  Future<void> _fetchExercises() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    setState(() {
      _exercises.clear();
      _exercises = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "exercise": Exercise(
            activity: doc['activity'] as String,
            duration: doc['duration'] as int,
            burnedCalories: doc['burnedCalories'] as int,
          ),
        };
      }).toList();
      _isLoading = false;
    });
  }

  /// Delete Exercise from Firestore and UI
  Future<void> _deleteExercise(String docId, int index) async {
    try {
      if (docId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('exercises').doc(docId).delete();
      }
      setState(() {
        _exercises.removeAt(index);
      });
    } catch (e) {
      print("Error deleting exercise: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Exercises", style: AppTextStyles.headline),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : _exercises.isEmpty
            ? const Center(
          child: Text(
            "No exercises added yet.",
            style: AppTextStyles.caption,
          ),
        )
            : ListView.builder(
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exerciseData = _exercises[index];
            final exercise = exerciseData["exercise"] as Exercise;
            final docId = exerciseData["id"] ?? "";

            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart, // SWIPE LEFT TO DELETE
              background: _buildDeleteBackground(),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmation(context);
              },
              onDismissed: (direction) {
                _deleteExercise(docId, index);
              },
              child: _buildExerciseCard(exercise),
            );
          },
        ),
      ),
      floatingActionButton: _buildAddExerciseFAB(),
      bottomNavigationBar: MyBottomNavigationBar(selectedIndexNavBar: 1),
    );
  }

  /// Floating Action Button
  Widget _buildAddExerciseFAB() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
        );
        _fetchExercises();
      },
      backgroundColor: Colors.black,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Swipe Left to Delete Background
  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }

  /// Delete Confirmation Dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Exercise", style: AppTextStyles.title),
        content: const Text("Are you sure you want to remove this exercise?", style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel", style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Build Exercise Card
  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(_getExerciseIcon(exercise.activity), color: Colors.black, size: 36),
        title: Text(exercise.activity, style: AppTextStyles.title),
        subtitle: Text(
          "${exercise.duration} min | ${exercise.burnedCalories} kcal",
          style: AppTextStyles.caption,
        ),
      ),
    );
  }

  /// Get Icons for Exercise Type
  IconData _getExerciseIcon(String activity) {
    switch (activity.toLowerCase()) {
      case "running":
        return Icons.directions_run;
      case "swimming":
        return Icons.pool;
      case "hiking":
        return Icons.terrain;
      case "cycling":
        return Icons.pedal_bike;
      default:
        return Icons.fitness_center;
    }
  }
}
