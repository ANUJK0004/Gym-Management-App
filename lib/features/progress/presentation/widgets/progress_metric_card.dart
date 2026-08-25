import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProgressMetricCard
    extends StatelessWidget {
  const ProgressMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.change,
    this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final double? change;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasChange =
        change != null;

    final isPositive =
        change != null &&
            change! > 0;

    final isNegative =
        change != null &&
            change! < 0;

    String changeText = '';

    if (change != null) {
      final prefix =
      change! > 0 ? '+' : '';

      changeText =
      '$prefix${change!.toStringAsFixed(1)} vs last month';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: Container(
          padding:
          const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            AppRadius.radiusMD,
            border: Border.all(
              color: AppColors.border,
              width: 0.5,
            ),
          ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Text(
            title,
            style:
            AppTextStyles.bodySmall
                .copyWith(
              color:
              AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,

            children: [
              Text(
                value,
                style:
                AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(width: 4),

              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 3,
                ),

                child: Text(
                  unit,
                  style:
                  AppTextStyles
                      .bodySmall
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ),
            ],
          ),

          if (hasChange) ...[
            const SizedBox(height: 6),

            Text(
              changeText,
              style:
              AppTextStyles
                  .labelMedium
                  .copyWith(
                color: isPositive
                    ? AppColors.success
                    : isNegative
                    ? AppColors.error
                    : AppColors
                    .textSecondary,

                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    ),
  ),
);
  }
}