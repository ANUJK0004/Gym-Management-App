import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import '../../../domain/entities/finance_export_request.dart';

class FinanceExportSectionSelector extends StatelessWidget {
  const FinanceExportSectionSelector({
    super.key,
    required this.selectedSections,
    required this.onChanged,
  });

  final Set<FinanceExportSection> selectedSections;
  final ValueChanged<Set<FinanceExportSection>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INCLUDE SECTIONS',
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        _SectionTile(
          title: 'Revenue Summary',
          section: FinanceExportSection.revenueSummary,
          selectedSections: selectedSections,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _SectionTile(
          title: 'Transaction History',
          section: FinanceExportSection.transactionHistory,
          selectedSections: selectedSections,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _SectionTile(
          title: 'Expense Breakdown',
          section: FinanceExportSection.expenseBreakdown,
          selectedSections: selectedSections,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        _SectionTile(
          title: 'Membership Stats',
          section: FinanceExportSection.membershipStats,
          selectedSections: selectedSections,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.section,
    required this.selectedSections,
    required this.onChanged,
  });

  final String title;
  final FinanceExportSection section;
  final Set<FinanceExportSection> selectedSections;
  final ValueChanged<Set<FinanceExportSection>> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selectedSections.contains(section);

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.10)
          : AppColors.inputField,
      borderRadius: AppRadius.radiusSM,
      child: InkWell(
        borderRadius: AppRadius.radiusSM,
        onTap: () {
          final updated =
          Set<FinanceExportSection>.from(
            selectedSections,
          );

          if (selected) {
            updated.remove(section);
          } else {
            updated.add(section);
          }

          onChanged(updated);
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusSM,
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration:
                const Duration(milliseconds: 150),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check,
                  size: 13,
                  color: AppColors.textInverse,
                )
                    : null,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style:
                  AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}