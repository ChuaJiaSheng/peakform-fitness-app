class Exercise {
  final String activity;
  final int duration; // in minutes
  final int burnedCalories;

  Exercise({
    required this.activity,
    required this.duration,
    required this.burnedCalories,
  }) {
    if (duration < 0) throw ArgumentError('Duration cannot be negative');
    if (burnedCalories < 0) throw ArgumentError('Burned calories cannot be negative');
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('name') || !json.containsKey('duration_minutes') || !json.containsKey('total_calories')) {
      throw Exception('Missing required fields in JSON');
    }
    return Exercise(
        activity: json['name'],
        duration: json['duration_minutes'],
        burnedCalories: json['total_calories']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': this.activity,
      'duration': this.duration,
      'burnedCalories': this.burnedCalories,
    };
  }
}
