import 'package:flutter/material.dart';

class AppTheme {
  // Adjusted color palette for softer white
  static const Color primaryYellow = Color(0xFFE7FE55);
  static const Color primaryBlue = Color(0xFF55CCFF);
  static const Color primaryOrange = Color(0xFFFEAF55);
  static const Color primaryWhite = Color(0xFFF8F9FA);  // Softer White
    static const Color lightGray = Color(0xFFEDEDED);  // Light Gray for contrast
  static const Color textBlack = Colors.black;
  static const Color textGrey = Colors.grey;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryWhite, // Updated softer white background
      scaffoldBackgroundColor: primaryWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryWhite,
        foregroundColor: textBlack, // Ensuring visibility
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryYellow,
        background: primaryWhite,
        error: primaryOrange,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: textBlack),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textBlack),
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textBlack),
        bodySmall: TextStyle(fontSize: 14, color: textGrey),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryBlue,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlue, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
        labelStyle: TextStyle(color: textBlack),
        hintStyle: TextStyle(color: textGrey),
      ),
    );
  }
}
