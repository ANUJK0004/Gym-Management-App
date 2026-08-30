import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class MembershipPlanSettingsCard extends StatelessWidget {
  const MembershipPlanSettingsCard({
    super.key,
    required this.planName,
    required this.price,
    required this.onTap,
    this.subtitle,
    this.isActive = true,
    this.isAddNew = false,
    this.showDivider = true,
  });

  final String planName;
  final String price;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isActive;
  final bool isAddNew;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isAddNew
                      ? Icons.add_circle_outline_rounded
                      : Icons.workspace_premium_rounded,
                  color: isAddNew
                      ? AppColors.owner
                      : isActive
                          ? Colors.amber
                          : AppColors.textDisabled,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              planName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isAddNew
                                    ? AppColors.owner
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isAddNew && !isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Inactive',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isAddNew)
                  Text(
                    price,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.owner,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.border,
          ),
      ],
    );
  }
}
