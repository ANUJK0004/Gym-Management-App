import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/app/theme/app_theme.dart';
import 'package:sweatsync/firebase_options.dart';
import 'package:sweatsync/screens/home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: SweatSync()));
}

class SweatSync extends StatelessWidget {
  const SweatSync({super.key});

  final bool onBoarding = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SweatSync - a manager",
      theme: AppTheme.darkTheme,
      home: const AuthTestScreen(),
    );
  }
}



