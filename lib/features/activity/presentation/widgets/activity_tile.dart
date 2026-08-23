import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/activity_log.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
  });

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _getIconAndColor(activity.type);
    final timeString = _formatTimeAgo(activity.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title.isNotEmpty
                      ? activity.title
                      : activity.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (activity.description.isNotEmpty &&
                    activity.description != activity.title) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeString,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getIconAndColor(String type) {
    switch (type) {
      // Member activities
      case 'memberJoined':
      case 'memberAssigned':
      case 'memberEnrollmentCreated':
      case 'memberInvitationSent':
        return (Icons.person_add_alt_1_rounded, AppColors.primary);

      case 'memberRemoved':
        return (Icons.person_remove_rounded, AppColors.error);

      // Trainer activities
      case 'trainerAdded':
      case 'trainerAssigned':
        return (Icons.directions_run_rounded, const Color(0xFF4A9EFF));

      case 'trainerRemoved':
        return (Icons.person_off_rounded, AppColors.error);

      // Membership & Payment activities
      case 'membershipPurchased':
      case 'membershipRenewed':
      case 'paymentReceived':
        return (Icons.payments_rounded, AppColors.primary);

      case 'paymentRefunded':
        return (Icons.money_off_rounded, AppColors.warning);

      // Membership Plan activities
      case 'membershipPlanCreated':
      case 'membershipPlanUpdated':
      case 'membershipPlanActivated':
        return (Icons.workspace_premium_rounded, AppColors.premium);

      case 'membershipPlanDeleted':
      case 'membershipPlanDeactivated':
        return (Icons.remove_circle_outline_rounded, AppColors.textSecondary);

      // Attendance
      case 'attendanceChecked':
        return (Icons.qr_code_scanner_rounded, AppColors.info);

      // Workout
      case 'workoutCreated':
      case 'workoutAssigned':
        return (Icons.fitness_center_rounded, AppColors.workout);

      // Profile / Gym updates
      case 'profileUpdated':
      case 'gymUpdated':
        return (Icons.edit_note_rounded, AppColors.textSecondary);

      default:
        return (Icons.notifications_active_rounded, AppColors.primary);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]}';
    }
  }
}