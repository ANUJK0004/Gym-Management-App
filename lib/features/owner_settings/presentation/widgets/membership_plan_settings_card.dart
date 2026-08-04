import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class MembershipPlanSettingsCard
    extends StatelessWidget {
  const MembershipPlanSettingsCard({
    super.key,
    required this.planName,
    required this.price,
    required this.onTap,
  });

  final String planName;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: Colors.amber,
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Text(
                planName,
                style:
                AppTextStyles.bodyMedium,
              ),
            ),

            Text(
              price,
              style: AppTextStyles
                  .labelMedium
                  .copyWith(
                color:
                AppColors.primary,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              size: 20,
              color:
              AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}