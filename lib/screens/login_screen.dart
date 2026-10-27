import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../models/fitness_user.dart';
import '../utilities/firebase_calls.dart';
import 'home_screen.dart';
import 'update_fitness_user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
              ],
            );
          } else {
            if (snapshot.data?.displayName == null) {
              return ProfileScreen(
                providers: [
                  EmailAuthProvider(),
                ],
              );
            } else {
              //check if User is found in fitnessUsers collection
              return FutureBuilder<FitnessUser>(
                future: FirebaseCalls().getFitnessUser(snapshot.data!.uid),
                builder: (context, snapshot2) {
                  if (snapshot2.hasData) {
                    if (newUser) {
                      return const UpdateFitnessUserScreen();
                    } else {
                      return HomeScreen();
                    }
                  } else if (snapshot2.hasError) {
                    return Text('${snapshot2.error}');
                  }
                  return const CircularProgressIndicator();
                },
              );
            }
          }
        },
      ),
    );
  }
}
