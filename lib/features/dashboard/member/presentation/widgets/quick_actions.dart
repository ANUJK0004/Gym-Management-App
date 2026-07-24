import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onWorkoutPressed,
    this.onProgressPressed,
    this.onMembershipPressed,
  });

  final VoidCallback? onWorkoutPressed;
  final VoidCallback? onProgressPressed;
  final VoidCallback? onMembershipPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.fitness_center,
            title: 'Workout',
            onTap: onWorkoutPressed,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _QuickAction(
            icon: Icons.show_chart,
            title: 'Progress',
            onTap: onProgressPressed,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _QuickAction(
            icon: Icons.card_membership,
            title: 'Membership',
            onTap: onMembershipPressed,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMD,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.radiusMD,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}