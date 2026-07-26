import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class MembershipCard extends StatelessWidget {
  const MembershipCard({
    super.key,
    required this.gymName,
    required this.status,
    this.expiryDate,
    this.onTap,
  });

  final String gymName;
  final String status;
  final DateTime? expiryDate;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.radiusLG,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENT GYM',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textInverse
                    .withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              gymName,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textInverse,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  '$status Membership',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ],
            ),

            if (expiryDate != null) ...[
              const SizedBox(height: 16),

              Text(
                'Membership expires',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textInverse
                      .withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${expiryDate!.day} '
                    '${_monthName(expiryDate!.month)} '
                    '${expiryDate!.year}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}