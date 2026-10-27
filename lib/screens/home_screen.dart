import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/bmi.dart';
import '../models/fitness_user.dart';
import '../utilities/api_calls.dart';
import '../widgets/navigation_bar.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

late Future<Bmi> _bmiFuture;

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  double burnedCalories = 0;
  double idealCalories = 2000;
  double idealWeight = 70;
  double currentWeight = 80;
  int totalDailyEE = 0;
  double bmiValue = 0.0;
  double bodyFat = 0.0;
  Map<String, dynamic>? _nextActivity;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBurnedCalories();
    _fetchNextWorkout();
    _bmiFuture = _fetchBmiAndTdeeData();
  }

  Future<Bmi> _fetchBmiAndTdeeData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in.");

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('fitnessUsers')
        .doc(uid)
        .get();

    if (!userDoc.exists) throw Exception("User data not found.");

    // Create FitnessUser object with necessary fields
    FitnessUser user = FitnessUser(
      height: userDoc.get('height'),
      weight: userDoc.get('weight'),
      age: userDoc.get('age'),
      gender: userDoc.get('gender'),
      exercise: userDoc.get('exercise'),
      idealWeight: userDoc.get('idealWeight'),
      idealCalories: userDoc.get('idealCalories'),
    );

    // Fetch BMI & TDEE from API
    Bmi bmiData = await ApiCalls().fetchBmi(user);
    setState(() {
      bmiValue = bmiData.bmi;
      totalDailyEE = bmiData.totalDailyEE;
      bodyFat = bmiData.bodyFatPercent;
    });

    print("Fetched BMI: ${bmiData.bmi}");
    print("Fetched TDEE: ${bmiData.totalDailyEE}");

    return bmiData; // Return fetched BMI & TDEE data
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('fitnessUsers')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          idealCalories = (snapshot.get('idealCalories') ?? 2000).toDouble();
          idealWeight = (snapshot.get('idealWeight') ?? 70).toDouble();
          currentWeight = (snapshot.get('weight') ?? 80).toDouble();
        });
      }
    });
  }

  // Future<void> _fetchTdee() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;
  //
  //   try {
  //     DocumentSnapshot userDoc =
  //     await FirebaseFirestore.instance.collection('fitnessUsers').doc(uid).get();
  //
  //     if (!userDoc.exists) return;
  //
  //     // Extract user details
  //     FitnessUser user = FitnessUser(
  //       height: userDoc.get('height'),
  //       weight: userDoc.get('weight'),
  //       age: userDoc.get('age').toInt(),
  //       gender: userDoc.get('gender'),
  //       exercise: userDoc.get('exercise'),
  //       idealWeight: userDoc.get('idealWeight'),
  //       idealCalories: userDoc.get('idealCalories'),
  //     );
  //
  //     // Fetch TDEE from API
  //     Bmi bmiData = await ApiCalls().fetchBmi(user);
  //
  //     setState(() {
  //       totalDailyEE = bmiData.totalDailyEE;
  //     });
  //
  //     print("TDEE: $totalDailyEE kcal/day"); t
  //
  //   } catch (e) {
  //     print("Error fetching TDEE: $e");
  //   }
  // }

  Future<void> _fetchBurnedCalories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('exercises')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      double totalCalories = 0;
      for (var doc in snapshot.docs) {
        totalCalories += (doc.get('burnedCalories') ?? 0).toDouble();
      }
      setState(() {
        burnedCalories = totalCalories;
      });
    });
  }

  Future<void> _fetchNextWorkout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('workoutPlans')
        .where('userId', isEqualTo: uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> allWorkouts =
          snapshot.docs.map((doc) => doc.data()).toList();

      // Define the correct order of days
      List<String> weekDays = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ];

      // Find the first available workout based on the week structure
      for (String day in weekDays) {
        for (var workout in allWorkouts) {
          for (var workoutDay in workout['workoutDays']) {
            if (workoutDay['day'] == day) {
              setState(() {
                _nextActivity = workoutDay;
              });
              print("Next workout found for: $day");
              return;
            }
          }
        }
      }
    } else {
      print("No workouts found for user $uid");
    }
  }

  void _changeTab(int direction) {
    setState(() {
      _selectedTab = (_selectedTab + direction) % 3;
      if (_selectedTab < 0) _selectedTab = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('Fitness Tracker', style: AppTextStyles.headline),
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTabSelection(),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (widget, animation) {
                return FadeTransition(opacity: animation, child: widget);
              },
              child: _buildCircularMetricWithAnimation(),
            ),
            const SizedBox(height: 20),
            _buildTdeeDisplay(),
            _buildBmiAndTdeeDisplay(),
            const SizedBox(height: 20),
            _buildNextActivity(),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(selectedIndexNavBar: 0),
    );
  }

  Widget _buildBmiAndTdeeDisplay() {
    return FutureBuilder<Bmi>(
      future: _bmiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const Text(
          'No data available',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  //  UI to display TDEE
  Widget _buildTdeeDisplay() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Total Daily EE: ${totalDailyEE} Kcal",
            style: AppTextStyles.headline,
          ),
          Text(
            "Body Fats Percentage: ${bodyFat}%",
            style: AppTextStyles.headline,
          )
        ],
      ),
    );
  }

  Widget _buildTabSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabButton("Calories", 0),
          _buildTabButton("BMI", 1),
          _buildTabButton("Weight Loss", 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _selectedTab == index
                  ? AppTheme.primaryBlue
                  : AppTheme.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedTab == index)
            Container(
              margin: const EdgeInsets.only(top: 5),
              height: 3,
              width: 40,
              color: AppTheme.primaryBlue,
            ),
        ],
      ),
    );
  }

  Widget _buildCircularMetricWithAnimation() {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_selectedTab),
      tween: Tween<double>(
        begin: 0,
        end: _selectedTab == 0
            ? burnedCalories
            : (_selectedTab == 1
                ? bmiValue
                : (currentWeight - idealWeight).abs()),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, animatedValue, child) {
        return _buildCircularMetric(animatedValue);
      },
    );
  }

  IconData _getMetricIcon() {
    switch (_selectedTab) {
      case 0:
        return Icons.local_fire_department; // Fire icon for Calories
      case 1:
        return Icons.accessibility; // Body icon for BMI
      case 2:
        return Icons.monitor_weight; // Weight scale icon for Weight Loss
      default:
        return Icons.help_outline; // Fallback icon
    }
  }

  Widget _buildCircularMetric(double animatedValue) {
    double value = animatedValue;
    double maxValue =
        _selectedTab == 0 ? idealCalories : (_selectedTab == 1 ? 40 : 20);
    String label =
        _selectedTab == 0 ? "Kcal" : (_selectedTab == 1 ? "BMI" : "Kg Lost");

    return Container(
      height: 350,
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.black, size: 40),
            onPressed: () => _changeTab(-1),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: CircularProgressIndicator(
                    value: value / maxValue > 1 ? 1 : value / maxValue,
                    backgroundColor: AppTheme.lightGray,
                    strokeWidth: 15,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getMetricIcon(), // Function to determine the correct icon
                      size: 50,
                      color: Colors.black, // Hardcoded for visibility
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Hardcoded color instead of theme
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.black, size: 40),
            onPressed: () => _changeTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildNextActivity() {
    if (_nextActivity == null ||
        _nextActivity!['exercises'] == null ||
        (_nextActivity!['exercises'] as List).isEmpty) {
      return const Center(
        child: Text(
          "No upcoming activities",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Extract the first exercise from the list
    var firstExercise = (_nextActivity!['exercises'] as List<dynamic>)[0];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppTheme.lightGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading:
              const Icon(Icons.directions_run, color: AppTheme.primaryYellow),
          title: Text(
            firstExercise['name'] ?? "Unknown Exercise",
            style: AppTextStyles.title,
          ),
          subtitle: Text(
            "Duration: ${firstExercise['duration'] ?? 'N/A'}",
            style: AppTextStyles.body,
          ),
        ),
      ),
    );
  }
}
