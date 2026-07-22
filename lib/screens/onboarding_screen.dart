import 'package:flutter/material.dart';
import 'package:sweatsync/screens/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/onboarding.png",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              fit: BoxFit.fitHeight,
              colorBlendMode: BlendMode.darken,
            ),
            const SizedBox(height: 20,),
            Text("Welcome to",style: Theme.of(context).textTheme.headlineMedium,),
            const SizedBox(height: 16,),
            Text("SweatSync",style: Theme.of(context).textTheme.displayLarge,),
            const SizedBox(height: 16,),

            Text("Your Fitness Journey",style: Theme.of(context).textTheme.headlineSmall,),
            Text("Starts Here",style: Theme.of(context).textTheme.headlineSmall,),
            const SizedBox(height: 16,),

            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Get Started"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
