import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_setup_provider.dart';

class FitnessGoalPage extends ConsumerWidget {
  const FitnessGoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileSetupProvider);

    final goals = [
      ('Lose Weight', Icons.trending_down),
      ('Build Muscle', Icons.fitness_center),
      ('Gain Weight', Icons.trending_up),
      ('Improve Fitness', Icons.directions_run),
      ('Maintain Fitness', Icons.favorite_outline),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your goals?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text('Choose your primary fitness goal.'),

          const SizedBox(height: 24),

          ...goals.map((goal) {
            final isSelected = profile.fitnessGoal == goal.$1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  ref
                      .read(profileSetupProvider.notifier)
                      .setFitnessGoal(goal.$1);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(goal.$2),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Text(
                          goal.$1,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                      if (isSelected) const Icon(Icons.check_circle),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          const Text(
            'Activity Level',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: profile.activityLevel,
            decoration: const InputDecoration(
              hintText: 'Select activity level',
            ),
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
              DropdownMenuItem(
                value: 'intermediate',
                child: Text('Intermediate'),
              ),
              DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              ref.read(profileSetupProvider.notifier).setActivityLevel(value);
            },
          ),
        ],
      ),
    );
  }
}
