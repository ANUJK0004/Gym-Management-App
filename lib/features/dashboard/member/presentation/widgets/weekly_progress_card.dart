import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({
    super.key,
    required this.completedWorkouts,
    required this.totalWorkouts,
  });

  final int completedWorkouts;
  final int totalWorkouts;

  @override
  Widget build(BuildContext context) {
    final progress = totalWorkouts == 0
        ? 0.0
        : completedWorkouts / totalWorkouts;

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
            'THIS WEEK',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
                  (index) {
                final completed =
                    index < completedWorkouts;

                return Column(
                  children: [
                    Text(
                      _dayName(index),
                      style:
                      AppTextStyles.bodySmall,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.primary
                            : AppColors.inputField,
                        shape: BoxShape.circle,
                      ),
                      child: completed
                          ? const Icon(
                        Icons.check,
                        size: 18,
                        color:
                        AppColors.textInverse,
                      )
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 8),

          Text(
            '$completedWorkouts of '
                '$totalWorkouts workouts completed',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int index) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return days[index];
  }
}