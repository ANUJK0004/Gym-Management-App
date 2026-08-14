import 'package:flutter/material.dart';
import 'package:sweatsync/features/report/presentation/widgets/export_report/report_export_sheet.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class ReportExportTypeStep extends StatelessWidget {
  const ReportExportTypeStep({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final ReportExportType? selectedType;
  final ValueChanged<ReportExportType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose the category of report to export.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ...ReportExportType.values.map(
                (type) => Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: _ReportTypeCard(
                type: type,
                selected: selectedType == type,
                onTap: () => onTypeSelected(type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeCard extends StatelessWidget {
  const _ReportTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ReportExportType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.radiusLG,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1D2A1B)
                : AppColors.background,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.14)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  type.icon,
                  style: const TextStyle(
                    fontSize: 19,
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
                      type.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}