import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  // Brand Colors

  static const Color primary = Color(0xFF7CF04A);
  static const Color primaryDark = Color(0xFF5FD62D);
  static const Color primaryLight = Color(0xFFA2F779);

  // Background Colors

  static const Color background = Color(0xFF111111);
  static const Color scaffold = Color(0xFF111111);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color card = Color(0xFF232323);
  static const Color bottomNav = Color(0xFF171717);
  static const Color inputField = Color(0xFF202020);

  // Text Colors

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9FA3A9);
  static const Color textHint = Color(0xFF707070);
  static const Color textDisabled = Color(0xFF5E5E5E);
  static const Color textInverse = Color(0xFF111111);

  // Border & Divider

  static const Color border = Color(0xFF343434);
  static const Color divider = Color(0xFF2C2C2C);

  // Status Colors

  static const Color success = Color(0xFF7CF04A);
  static const Color error = Color(0xFFFF5D5D);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF4A9EFF);

  // Module Accent Colors

  static const Color workout = Color(0xFFFF8A00);
  static const Color nutrition = Color(0xFFFFC93C);
  static const Color progress = Color(0xFF8E5CFF);
  static const Color profile = Color(0xFF7A3EFF);

  // Exercise Status

  static const Color activeExercise = Color(0xFF7CF04A);
  static const Color completedExercise = Color(0xFF4CAF50);
  static const Color upcomingExercise = Color(0xFF3A3A3A);

  // Membership

  static const Color premium = Color(0xFFFFD54F);
  static const Color gold = Color(0xFFFFC107);
  static const Color silver = Color(0xFFBDBDBD);
  static const Color bronze = Color(0xFFB87333);

  // Overlay Colors

  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x33FFFFFF);

  // Gradient Colors

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF7CF04A),
      Color(0xFF5FD62D),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient workoutGradient = LinearGradient(
    colors: [
      Color(0xFF7CF04A),
      Color(0xFF9EF768),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF1B1B1B),
      Color(0xFF111111),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}