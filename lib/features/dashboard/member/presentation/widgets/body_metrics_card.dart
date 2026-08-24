import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class BodyMetricsCard extends StatelessWidget {
  const BodyMetricsCard({
    super.key,
    required this.currentWeight,
    required this.previousWeight,
    this.monthlyWorkouts = 0,
    this.workoutChange = 0,
    this.onViewProgress,
  });

  final double currentWeight;
  final double previousWeight;
  final int monthlyWorkouts;
  final int workoutChange;

  final VoidCallback? onViewProgress;

  @override
  Widget build(BuildContext context) {
    final difference = currentWeight - previousWeight;
    final isDown = difference < 0;

    final workoutSubtitle = workoutChange > 0
        ? '+$workoutChange this month'
        : (workoutChange < 0
        ? '$workoutChange this month'
        : (monthlyWorkouts > 0 ? 'Logged this month' : 'No workouts yet'));

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR PROGRESS',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Weight',
                value: currentWeight > 0
                    ? '${currentWeight.toStringAsFixed(1)} kg'
                    : '--',
                subtitle: currentWeight > 0 && previousWeight > 0 && difference.abs() > 0.01
                    ? '${isDown ? '↓' : '↑'} ${difference.abs().toStringAsFixed(1)} kg'
                    : 'Current Weight',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _MetricCard(
                title: 'Workouts',
                value: '$monthlyWorkouts',
                subtitle: workoutSubtitle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: onViewProgress,
          child: const Text(
            'View full progress',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: AppTextStyles.headlineMedium,
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}