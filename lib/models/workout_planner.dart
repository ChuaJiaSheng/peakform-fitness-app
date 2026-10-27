class WorkoutPlanModel {
  final String goal;
  final String fitnessLevel;
  final int totalWeeks;
  final int daysPerWeek;
  final int sessionDuration;
  final List<WorkoutDay> workoutDays;
  final String seoTitle;
  final String seoContent;

  WorkoutPlanModel({
    required this.goal,
    required this.fitnessLevel,
    required this.totalWeeks,
    required this.daysPerWeek,
    required this.sessionDuration,
    required this.workoutDays,
    required this.seoTitle,
    required this.seoContent,
  });

  /// Convert JSON response to `WorkoutPlanModel`
  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      goal: json['result']['goal'] ?? 'Not Provided',
      fitnessLevel: json['result']['fitness_level'] ?? 'Not Provided',
      totalWeeks: json['result']['total_weeks'] ?? 4,
      daysPerWeek: json['result']['schedule']['days_per_week'] ?? 4,
      sessionDuration: json['result']['schedule']['session_duration'] ?? 60,
      workoutDays: (json['result']['exercises'] as List<dynamic>)
          .map((day) => WorkoutDay.fromJson(day))
          .toList(),
      seoTitle: json['result']['seo_title'] ?? '',
      seoContent: json['result']['seo_content'] ?? '',
    );
  }
}

class WorkoutDay {
  final String day;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.day,
    required this.exercises,
  });

  /// Convert JSON response to `WorkoutDay`
  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'] ?? 'Unknown',
      exercises: (json['exercises'] as List<dynamic>)
          .map((exercise) => Exercise.fromJson(exercise))
          .toList(),
    );
  }
}

class Exercise {
  final String name;
  final String duration;
  final String repetitions;
  final String sets;
  final String equipment;

  Exercise({
    required this.name,
    required this.duration,
    required this.repetitions,
    required this.sets,
    required this.equipment,
  });

  /// Convert JSON response to `Exercise`
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? 'Unknown Exercise',
      duration: json['duration'] ?? 'Unknown Duration',
      repetitions: json['repetitions'] ?? '-',
      sets: json['sets'] ?? '-',
      equipment: json['equipment'] ?? 'None',
    );
  }
}
