import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../design_system/buttons/primary_button.dart';

class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({
    super.key,
    required this.workoutName,
    required this.description,
    required this.exerciseCount,
    required this.duration,
    this.onStartWorkout,
  });

  final String workoutName;
  final String description;
  final int exerciseCount;
  final int duration;

  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WORKOUT",
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            workoutName,
            style: AppTextStyles.headlineMedium,
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 18,
              ),

              const SizedBox(width: 6),

              Text('$exerciseCount Exercises'),

              const SizedBox(width: 20),

              const Icon(
                Icons.timer_outlined,
                size: 18,
              ),

              const SizedBox(width: 6),

              Text('~$duration min'),
            ],
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            text: 'Start Workout',
            icon: Icons.play_arrow_rounded,
            onPressed: onStartWorkout,
          ),
        ],
      ),
    );
  }
}