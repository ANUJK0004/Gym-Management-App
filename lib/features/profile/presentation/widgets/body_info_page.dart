import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/design_system/inputs/app_slider.dart';

import '../providers/profile_setup_provider.dart';

class BodyInfoPage extends ConsumerWidget {
  const BodyInfoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileSetupProvider);
    final notifier = ref.read(
      profileSetupProvider.notifier,
    );

    final height = profile.height ?? 170;
    final weight = profile.weight ?? 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'Your body information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'This helps us calculate your fitness metrics and personalize your plan.',
          ),

          const SizedBox(height: 40),

          AppSlider(
            label: 'Height',
            value: height,
            min: 100,
            max: 220,
            divisions: 120,
            suffix: 'cm',
            onChanged: notifier.setHeight,
          ),

          const SizedBox(height: 40),

          AppSlider(
            label: 'Weight',
            value: weight,
            min: 30,
            max: 200,
            divisions: 170,
            suffix: 'kg',
            onChanged: notifier.setWeight,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}