import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_intake.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final TextEditingController _waterAmountController = TextEditingController();
  double _totalIntake = 0;

  @override
  void initState() {
    super.initState();
    _fetchWaterIntake();
  }

  /// **Fetch user's total water intake for today**
  Future<void> _fetchWaterIntake() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('water_intake')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('timestamp',
        isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(hours: 24)))
        .get();

    double total = snapshot.docs.fold(0, (sum, doc) {
      return sum + (doc['amount'] as double);
    });

    setState(() {
      _totalIntake = total;
    });
  }

  /// **Log new water intake entry**
  Future<void> _addWaterIntake() async {
    final double amount = double.tryParse(_waterAmountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid water amount!')),
      );
      return;
    }

    final newEntry = WaterIntake(amount: amount, timestamp: DateTime.now());

    await FirebaseFirestore.instance.collection('water_intake').add({
      'amount': newEntry.amount,
      'timestamp': newEntry.timestamp,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });

    setState(() {
      _totalIntake += amount;
      _waterAmountController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Water intake added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Tracker'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Container(
        color: const Color(0xFF1A1A1A),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Today’s Water Intake: $_totalIntake ml',
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildWaterInput(),
            const SizedBox(height: 20),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterInput() {
    return TextField(
      controller: _waterAmountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Enter water amount (ml)',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _addWaterIntake,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Log Water Intake', style: TextStyle(fontSize: 16)),
    );
  }
}
