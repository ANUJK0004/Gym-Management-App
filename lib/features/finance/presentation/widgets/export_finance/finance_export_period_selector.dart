import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import '../../../domain/entities/finance_export_request.dart';

class FinanceExportPeriodSelector extends StatelessWidget {
  const FinanceExportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final FinanceExportPeriod selectedPeriod;
  final ValueChanged<FinanceExportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIME PERIOD',
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PeriodButton(
                title: 'This Month',
                period: FinanceExportPeriod.thisMonth,
                selectedPeriod: selectedPeriod,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PeriodButton(
                title: 'Last Month',
                period: FinanceExportPeriod.lastMonth,
                selectedPeriod: selectedPeriod,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _PeriodButton(
                title: 'This Quarter',
                period: FinanceExportPeriod.thisQuarter,
                selectedPeriod: selectedPeriod,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PeriodButton(
                title: 'This Year',
                period: FinanceExportPeriod.thisYear,
                selectedPeriod: selectedPeriod,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.title,
    required this.period,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final String title;
  final FinanceExportPeriod period;
  final FinanceExportPeriod selectedPeriod;
  final ValueChanged<FinanceExportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = period == selectedPeriod;

    return Material(
      color: selected
          ? AppColors.primary.withOpacity(0.14)
          : AppColors.inputField,
      borderRadius: AppRadius.radiusSM,
      child: InkWell(
        borderRadius: AppRadius.radiusSM,
        onTap: () => onChanged(period),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusSM,
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.55)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 11,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}