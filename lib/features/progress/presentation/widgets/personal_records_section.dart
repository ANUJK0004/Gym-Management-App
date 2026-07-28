import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/progress.dart';

class PersonalRecordsSection
    extends StatelessWidget {
  const PersonalRecordsSection({
    super.key,
    required this.records,
  });

  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          'PERSONAL RECORDS',
          style: AppTextStyles
              .labelMedium
              .copyWith(
            color:
            AppColors.textSecondary,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        if (records.isEmpty)
          _EmptyRecordsCard()
        else
          ...records.map(
                (record) =>
                _RecordCard(
                  record: record,
                ),
          ),
      ],
    );
  }
}

class _EmptyRecordsCard
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),

      child: Text(
        'No personal records yet.',
        textAlign:
        TextAlign.center,

        style: AppTextStyles
            .bodyMedium
            .copyWith(
          color:
          AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RecordCard
    extends StatelessWidget {
  const _RecordCard({
    required this.record,
  });

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration:
            BoxDecoration(
              color:
              AppColors.background,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),

            child: const Center(
              child: Text(
                '🏆',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  record.exerciseName,
                  style: AppTextStyles
                      .bodyMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  record.formattedDate,
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${record.weight.toStringAsFixed(0)} kg',
            style: AppTextStyles
                .bodyLarge
                .copyWith(
              color:
              AppColors.primary,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}