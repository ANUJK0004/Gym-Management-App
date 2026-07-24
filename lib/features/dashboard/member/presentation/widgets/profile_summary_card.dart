import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    this.fitnessGoal,
    this.activityLevel,
    this.height,
    this.weight,
    this.onEditProfile,
  });

  final String? fitnessGoal;
  final String? activityLevel;
  final double? height;
  final double? weight;

  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // HEADER
          // --------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Fitness',
                  style: AppTextStyles.titleMedium,
                ),
              ),

              if (onEditProfile != null)
                IconButton(
                  onPressed: onEditProfile,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  tooltip: 'Edit profile',
                ),
            ],
          ),

          const SizedBox(height: 4),

          // --------------------------------------------------
          // FITNESS GOAL
          // --------------------------------------------------
          Text(
            fitnessGoal ?? 'Set your fitness goal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 16),

          // --------------------------------------------------
          // FITNESS METRICS
          // --------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _ProfileMetric(
                  label: 'Height',
                  value: height != null
                      ? '${height!.toStringAsFixed(0)} cm'
                      : '--',
                ),
              ),

              Expanded(
                child: _ProfileMetric(
                  label: 'Weight',
                  value: weight != null
                      ? '${weight!.toStringAsFixed(1)} kg'
                      : '--',
                ),
              ),

              Expanded(
                child: _ProfileMetric(
                  label: 'Activity',
                  value: activityLevel ?? '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}