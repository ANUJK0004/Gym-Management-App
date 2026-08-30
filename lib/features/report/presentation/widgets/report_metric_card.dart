import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.change,
    this.changePositiveIsGood = true,
  });

  final IconData icon;
  final String value;
  final String label;
  final String change;
  final bool changePositiveIsGood;

  @override
  Widget build(BuildContext context) {
    final number =
        double.tryParse(change.replaceAll(RegExp(r'[^0-9.-]'), ''));

    final isPositive = (number ?? 0) >= 0;
    final isGood = changePositiveIsGood
        ? isPositive
        : !isPositive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: AppColors.owner,
              ),
              const Spacer(),
              Text(
                change,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isGood
                      ? AppColors.owner
                      : Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
