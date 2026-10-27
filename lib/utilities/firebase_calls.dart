import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/fitness_user.dart';

late FitnessUser fitnessUser;
bool newUser = false;

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference fitnessUsersCollection =
    FirebaseFirestore.instance.collection('fitnessUsers');

class FirebaseCalls {
  /// **Fetch Fitness User Data**
  Future<FitnessUser> getFitnessUser(String uid) async {
    DocumentSnapshot docSnap = await fitnessUsersCollection.doc(uid).get();

    if (docSnap.exists) {
      fitnessUser = FitnessUser(
        weight: docSnap.get('weight'),
        height: docSnap.get('height'),
        gender: docSnap.get('gender'),
        age: docSnap.get('age'),
        exercise: docSnap.get('exercise'),
        idealWeight: docSnap.get('idealWeight'),
        idealCalories: docSnap.get('idealCalories'),
      );
    } else {
      newUser = true;
      fitnessUser = FitnessUser(
        weight: 50,
        height: 160,
        gender: 'Male',
        age: 18,
        exercise: 'Sedentary',
        idealWeight: 70,
        idealCalories: 2500,
      );
    }
    return fitnessUser;
  }

  /// **Update User Data (FIXED)**
  Future<void> updateFitnessUser(FitnessUser fitnessUser) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid == null) {
        print("ERROR: No authenticated user found.");
        return;
      }

      DocumentReference userDoc = fitnessUsersCollection.doc(uid);
      DocumentSnapshot docSnap = await userDoc.get();

      if (docSnap.exists) {
        // **Update existing user document**
        await userDoc.update({
          'weight': fitnessUser.weight,
          'height': fitnessUser.height,
          'gender': fitnessUser.gender,
          'age': fitnessUser.age,
          'exercise': fitnessUser.exercise,
          'idealWeight': fitnessUser.idealWeight,
          'idealCalories': fitnessUser.idealCalories,
        });

        print("Successfully updated user data in Firestore!");
      } else {
        // **Create a new user document if not found**
        await userDoc.set({
          'weight': fitnessUser.weight,
          'height': fitnessUser.height,
          'gender': fitnessUser.gender,
          'age': fitnessUser.age,
          'exercise': fitnessUser.exercise,
          'idealWeight': fitnessUser.idealWeight,
          'idealCalories': fitnessUser.idealCalories,
        });

        print("New user document created in Firestore!");
      }
    } catch (e) {
      print("ERROR updating fitness data: $e");
    }
  }
}
