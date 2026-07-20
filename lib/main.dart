import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sweatsync/firebase_options.dart';
import 'package:sweatsync/screens/login_screen.dart';
import 'package:sweatsync/screens/onboarding_screen.dart';
import 'package:sweatsync/app/theme/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: onBoarding ? const OnboardingScreen() : LoginScreen(),
    );
  }
}


