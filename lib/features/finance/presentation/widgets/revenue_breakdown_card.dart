import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/revenue_breakdown.dart';

class RevenueBreakdownCard
    extends StatelessWidget {
  const RevenueBreakdownCard({
    super.key,
    required this.breakdown,
  });

  final RevenueBreakdown breakdown;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(
        12,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  breakdown.category,
                  style:
                  AppTextStyles
                      .bodyMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '₹${breakdown.amount.toStringAsFixed(0)}',
                style:
                AppTextStyles
                    .bodyMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          Align(
            alignment:
            Alignment.centerRight,
            child: Text(
              '${breakdown.percentage.toStringAsFixed(0)}%',
              style:
              AppTextStyles
                  .labelMedium
                  .copyWith(
                color:
                AppColors
                    .textSecondary,
                fontSize: 9,
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              4,
            ),
            child:
            LinearProgressIndicator(
              value:
              (breakdown.percentage /
                  100)
                  .clamp(
                0.0,
                1.0,
              ),
              minHeight: 4,
              backgroundColor:
              AppColors.border,
              valueColor:
              const AlwaysStoppedAnimation<
                  Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}