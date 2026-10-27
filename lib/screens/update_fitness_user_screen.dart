import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/fitness_user.dart';
import '../utilities/firebase_calls.dart';
import '../widgets/navigation_bar.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class UpdateFitnessUserScreen extends StatefulWidget {
  const UpdateFitnessUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateFitnessUserScreen> createState() => _UpdateFitnessUserScreenState();
}

class _UpdateFitnessUserScreenState extends State<UpdateFitnessUserScreen> {
  final FirebaseCalls firebaseCalls = FirebaseCalls();

  double selectedWeight = 60.0;
  double selectedHeight = 170.0;
  double idealWeight = 70.0;
  double idealCalories = 2000.0;
  int selectedAge = 21;
  String? selectedGender;
  String? selectedActivityLevel;

  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> activityLevels = ["Beginner", "Intermediate", "Advanced"];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      FitnessUser fitnessUser = await firebaseCalls.getFitnessUser(userId);
      setState(() {
        selectedWeight = fitnessUser.weight.toDouble();
        selectedHeight = fitnessUser.height.toDouble();
        idealWeight = fitnessUser.idealWeight.toDouble();
        selectedAge = fitnessUser.age;
        idealCalories = fitnessUser.idealCalories.toDouble().clamp(1500, 4000);
        selectedGender = fitnessUser.gender;
        selectedActivityLevel = fitnessUser.exercise;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _updateUserData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      FitnessUser updatedUser = FitnessUser(
        weight: selectedWeight.toInt(),
        height: selectedHeight.toInt(),
        gender: selectedGender ?? "Male",
        age: selectedAge,
        exercise: selectedActivityLevel ?? "Beginner",
        idealWeight: idealWeight.toInt(),
        idealCalories: idealCalories.toInt(),
      );

      await firebaseCalls.updateFitnessUser(updatedUser);
      await _fetchUserData();
      print("User data updated successfully!");
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("ERROR updating user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavigationBar(selectedIndexNavBar: 2),
      appBar: AppBar(
        title: const Text('Update Your Fitness Info', style: AppTextStyles.headline),
        backgroundColor: AppTheme.primaryWhite,
      ),
      backgroundColor: AppTheme.primaryWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,  // Softer background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildGenderSelection(),
                const SizedBox(height: 40),
                _buildAgeSelection(),
                const SizedBox(height: 40),
                _buildSliderWithLabel("What’s your current weight?", selectedWeight, 30, 150, (value) {
                  setState(() => selectedWeight = value);
                }),
                const SizedBox(height: 40),
                _buildSliderWithLabel("What’s your height?", selectedHeight, 140, 220, (value) {
                  setState(() => selectedHeight = value);
                }),
                const SizedBox(height: 40),
                _buildSliderWithLabel("What’s your ideal weight?", idealWeight, 30, 150, (value) {
                  setState(() => idealWeight = value);
                }),
                const SizedBox(height: 40),
                _buildSliderWithLabel("Ideal Caloric Burn (kcal)", idealCalories, 1500, 4000, (value) {
                  setState(() => idealCalories = value);
                }),
                const SizedBox(height: 50),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("What is your gender?", style: AppTextStyles.title),
        const SizedBox(height: 10),
        ...genderOptions.map((gender) => RadioListTile<String>(
          activeColor: AppTheme.primaryYellow,
          title: Text(gender, style: AppTextStyles.body),
          value: gender,
          groupValue: selectedGender,
          onChanged: (value) {
            setState(() => selectedGender = value);
          },
        )),
      ],
    );
  }

  Widget _buildAgeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Your Age", style: AppTextStyles.title),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              int age = 12 + index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAge = age;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "$age",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selectedAge == age ? AppTheme.primaryYellow : AppTheme.textBlack,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderWithLabel(String title, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${min.toInt()}", style: AppTextStyles.caption),
            Text("${value.toInt()}", style: AppTextStyles.body),
            Text("${max.toInt()}", style: AppTextStyles.caption),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppTheme.primaryYellow,
          inactiveColor: AppTheme.textGrey,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActivityLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("What is your fitness level?", style: AppTextStyles.title),
        const SizedBox(height: 10),
        ...activityLevels.map((level) => RadioListTile<String>(
          activeColor: AppTheme.primaryYellow,
          title: Text(level, style: AppTextStyles.body),
          value: level,
          groupValue: selectedActivityLevel,
          onChanged: (value) {
            setState(() => selectedActivityLevel = value);
          },
        )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        ),
        child: const Text('Save', style: AppTextStyles.button),
      ),
    );
  }
}
