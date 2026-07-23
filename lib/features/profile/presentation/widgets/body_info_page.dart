import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_setup_provider.dart';

class BodyInfoPage extends ConsumerWidget {
  const BodyInfoPage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final profile =
    ref.watch(profileSetupProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Text(
            'Your body metrics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'These measurements help us '
                'personalize your fitness experience.',
          ),

          const SizedBox(height: 40),

          const Text(
            'Height',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Slider(
            min: 100,
            max: 230,
            divisions: 130,
            value:
            profile.height ?? 170,
            label:
            '${(profile.height ?? 170).round()} cm',
            onChanged: (value) {
              ref
                  .read(
                profileSetupProvider
                    .notifier,
              )
                  .setHeight(value);
            },
          ),

          Center(
            child: Text(
              '${(profile.height ?? 170).round()} cm',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 48),

          const Text(
            'Weight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Slider(
            min: 30,
            max: 200,
            divisions: 170,
            value:
            profile.weight ?? 70,
            label:
            '${(profile.weight ?? 70).round()} kg',
            onChanged: (value) {
              ref
                  .read(
                profileSetupProvider
                    .notifier,
              )
                  .setWeight(value);
            },
          ),

          Center(
            child: Text(
              '${(profile.weight ?? 70).round()} kg',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}