class Bmi {
  final double bmi;
  final double bodyFatPercent;
  final double leanBodyMass;
  final int totalDailyEE;
  final double basalMetabolicRate;

  Bmi({
    required this.bmi,
    required this.bodyFatPercent,
    required this.leanBodyMass,
    required this.totalDailyEE,
    required this.basalMetabolicRate,
  });

  factory Bmi.fromJson(Map<String, dynamic> json) {
    try {
      return Bmi(
        bmi: (json['bodyMassIndex']?['value'] ?? 0).toDouble(),
        bodyFatPercent:
            (json['bodyFatPercentage']?['bmi']?['value'] ?? 0).toDouble(),
        leanBodyMass: (json['leanBodyMass']?['bmi']?['value'] ?? 0).toDouble(),
        totalDailyEE: (json['restingDailyEnergyExpenditure']?['bmi']
                    ?['calories']?['value'] ??
                0)
            .toInt(),
        basalMetabolicRate:
            (json['basalMetabolicRate']?['msj']?['calories']?['value'] ?? 0)
                .toDouble(),
      );
    } catch (e, stacktrace) {
      print("ERROR parsing Bmi JSON: $e");
      print("Stacktrace: $stacktrace");
      throw Exception("Failed to parse BMI data");
    }
  }
}
