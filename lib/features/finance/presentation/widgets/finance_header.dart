import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

class FinanceHeader extends StatelessWidget {
  const FinanceHeader({
    super.key,
    required this.onExport,
  });

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finance',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Revenue & expenses',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: AppRadius.radiusSM,
          child: InkWell(
            onTap: onExport,
            borderRadius: AppRadius.radiusSM,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Export',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}