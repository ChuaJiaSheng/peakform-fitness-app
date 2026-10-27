import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_planner.dart';

class WorkoutFirebase {
  final CollectionReference workoutPlanCollection =
  FirebaseFirestore.instance.collection('workoutPlans');

  Future<void> addWorkoutPlan(WorkoutPlanModel plan) async {
    await workoutPlanCollection.add({
      'goal': plan.goal,
      'fitnessLevel': plan.fitnessLevel,
      'totalWeeks': plan.totalWeeks,
      'daysPerWeek': plan.daysPerWeek,
      'sessionDuration': plan.sessionDuration,
      'seoTitle': plan.seoTitle,
      'seoContent': plan.seoContent,
      'workoutDays': plan.workoutDays.map((day) => {
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
  }

  Stream<List<WorkoutPlanModel>> getWorkoutPlans() {
    return workoutPlanCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkoutPlanModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
