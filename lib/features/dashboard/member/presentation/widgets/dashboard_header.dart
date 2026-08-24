import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.name,
    this.photoUrl,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  final String name;
  final String? photoUrl;

  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning 👋';
    } else if (hour < 17) {
      return 'Good afternoon 👋';
    } else {
      return 'Good evening 👋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Member' : name;

    return Row(
      children: [
        GestureDetector(
          onTap: onProfilePressed,
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            backgroundImage: photoUrl != null && photoUrl!.trim().isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.trim().isEmpty
                ? const Icon(
              Icons.person,
              color: AppColors.textInverse,
            )
                : null,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                displayName,
                style: AppTextStyles.headlineMedium,
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onNotificationPressed,
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}