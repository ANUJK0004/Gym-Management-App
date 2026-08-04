import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/revenue_trend.dart';

enum RevenueTrendPeriod {
  month,
  quarter,
  year,
}

class RevenueTrendCard
    extends StatelessWidget {
  const RevenueTrendCard({
    super.key,
    required this.trends,
    required this.period,
    required this.onPeriodChanged,
  });

  final List<RevenueTrend> trends;

  final RevenueTrendPeriod period;

  final ValueChanged<
      RevenueTrendPeriod>
  onPeriodChanged;

  @override
  Widget build(
      BuildContext context,
      ) {
    final maxValue =
    trends.isEmpty
        ? 1.0
        : trends
        .map(
          (item) =>
      item.amount,
    )
        .reduce(
          (a, b) =>
      a > b
          ? a
          : b,
    );

    return Container(
      height: 190,
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
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
              Text(
                'Revenue Trend',
                style:
                AppTextStyles
                    .titleMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const Spacer(),

              _periodButton(
                label: 'Month',
                value:
                RevenueTrendPeriod
                    .month,
              ),

              _periodButton(
                label: 'Quarter',
                value:
                RevenueTrendPeriod
                    .quarter,
              ),

              _periodButton(
                label: 'Year',
                value:
                RevenueTrendPeriod
                    .year,
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Expanded(
            child:
            trends.isEmpty
                ? Center(
              child:
              Text(
                'No revenue data available',
                style:
                AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),
            )
                : Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .end,
              children:
              trends.map(
                    (trend) {
                  final height =
                      trend.amount /
                          maxValue;

                  return Expanded(
                    child:
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        3,
                      ),
                      child:
                      FractionallySizedBox(
                        heightFactor:
                        height
                            .clamp(
                          0.05,
                          1.0,
                        ),
                        alignment:
                        Alignment
                            .bottomCenter,
                        child:
                        Container(
                          decoration:
                          BoxDecoration(
                            color:
                            AppColors
                                .primary,
                            borderRadius:
                            const BorderRadius
                                .vertical(
                              top:
                              Radius.circular(
                                4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton({
    required String label,
    required RevenueTrendPeriod value,
  }) {
    final selected =
        period == value;

    return GestureDetector(
      onTap: () =>
          onPeriodChanged(
            value,
          ),
      child: Container(
        margin:
        const EdgeInsets.only(
          left: 5,
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            7,
          ),
        ),
        child: Text(
          label,
          style:
          TextStyle(
            color: selected
                ? Colors.black
                : AppColors
                .textSecondary,
            fontSize: 9,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),
    );
  }
}