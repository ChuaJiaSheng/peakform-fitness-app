class FitnessUser {
  int weight;
  int height;
  String gender;
  int age;
  String exercise;
  int idealWeight;
  int idealCalories;

  FitnessUser({
    required this.weight,
    required this.height,
    required this.gender,
    required this.age,
    required this.exercise,
    required this.idealWeight,
    required this.idealCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'gender': gender,
      'age': age,
      'exercise': exercise,
      'idealWeight': idealWeight,
      'idealCalories': idealCalories,
    };
  }

  factory FitnessUser.fromJson(Map<String, dynamic> json) {
    return FitnessUser(
      weight: json['weight'] ?? 50,
      height: json['height'] ?? 160,
      gender: json['gender'] ?? "Male",
      age: json['age'] ?? 18,
      exercise: json['exercise'] ?? "None",
      idealWeight: json['idealWeight'] ?? 60,
      idealCalories: json['idealCalories'] ?? 2500,
    );
  }
}
