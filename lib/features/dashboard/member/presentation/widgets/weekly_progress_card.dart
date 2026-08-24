import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({
    super.key,
    required this.completedWorkouts,
    required this.totalWorkouts,
    this.weeklyActivity = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
  });

  final int completedWorkouts;
  final int totalWorkouts;
  final List<bool> weeklyActivity;

  @override
  Widget build(BuildContext context) {
    final progress = totalWorkouts == 0
        ? 0.0
        : (completedWorkouts / totalWorkouts).clamp(0.0, 1.0);

    final currentWeekdayIndex = DateTime.now().weekday - 1; // 0 = Mon, 6 = Sun

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THIS WEEK',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$completedWorkouts Completed',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
                  (index) {
                final completed = index < weeklyActivity.length
                    ? weeklyActivity[index]
                    : false;

                final isToday = index == currentWeekdayIndex;

                return Column(
                  children: [
                    Text(
                      _dayName(index),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.primary
                            : (isToday
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.inputField),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        )
                            : null,
                      ),
                      child: completed
                          ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.textInverse,
                      )
                          : (isToday
                          ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                          : null),
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