import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntake {
  final double amount; // in milliliters
  final DateTime timestamp;

  WaterIntake({
    required this.amount,
    required this.timestamp,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      amount: json['amount'] as double,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
