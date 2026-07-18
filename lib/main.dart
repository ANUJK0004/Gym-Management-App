import 'package:flutter/material.dart';
import 'package:sweatsync/screens/home_screen.dart';
import 'package:sweatsync/screens/onboarding_screen.dart';
import 'package:sweatsync/theme/app_theme.dart';

void main() {
  runApp(const SweatSync());
}

class SweatSync extends StatelessWidget {
  const SweatSync({super.key});

  final bool onBoarding = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SweatSync - a manager",
      theme: AppTheme.darkTheme(),
      home: onBoarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}


