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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onProfilePressed,
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            backgroundImage: photoUrl != null
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null
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
                'Good morning 👋',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                name,
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
        ),
      ],
    );
  }
}