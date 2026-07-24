import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/design_system/cards/selection_card.dart';

import '../providers/profile_setup_provider.dart';

class FitnessGoalPage extends ConsumerWidget {
  const FitnessGoalPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileSetupProvider);
    final notifier = ref.read(
      profileSetupProvider.notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'Set your fitness goals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose your primary goal and current activity level.',
          ),

          const SizedBox(height: 32),

          const Text(
            'Fitness Goal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Build Muscle',
            subtitle: 'Increase muscle mass and strength',
            icon: Icons.fitness_center,
            selected:
            profile.fitnessGoal == 'Build Muscle',
            onTap: () {
              notifier.setFitnessGoal('Build Muscle');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Lose Weight',
            subtitle: 'Reduce body fat and improve health',
            icon: Icons.monitor_weight_outlined,
            selected:
            profile.fitnessGoal == 'Lose Weight',
            onTap: () {
              notifier.setFitnessGoal('Lose Weight');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Improve Fitness',
            subtitle: 'Improve strength, endurance and health',
            icon: Icons.directions_run,
            selected:
            profile.fitnessGoal == 'Improve Fitness',
            onTap: () {
              notifier.setFitnessGoal('Improve Fitness');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Maintain Weight',
            subtitle: 'Stay healthy and maintain your current weight',
            icon: Icons.balance,
            selected:
            profile.fitnessGoal == 'Maintain Weight',
            onTap: () {
              notifier.setFitnessGoal('Maintain Weight');
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Beginner',
            subtitle: 'New to regular exercise',
            icon: Icons.directions_walk,
            selected:
            profile.activityLevel == 'Beginner',
            onTap: () {
              notifier.setActivityLevel('Beginner');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Intermediate',
            subtitle: 'Exercise regularly',
            icon: Icons.directions_run,
            selected:
            profile.activityLevel == 'Intermediate',
            onTap: () {
              notifier.setActivityLevel('Intermediate');
            },
          ),

          const SizedBox(height: 12),

          SelectionCard(
            title: 'Advanced',
            subtitle: 'Highly experienced and consistent',
            icon: Icons.fitness_center,
            selected:
            profile.activityLevel == 'Advanced',
            onTap: () {
              notifier.setActivityLevel('Advanced');
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}