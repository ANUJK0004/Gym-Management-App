import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../domain/entities/report_export_request.dart';
import 'report_export_sheet.dart';

class ReportExportContentStep extends StatelessWidget {
  const ReportExportContentStep({
    super.key,
    required this.reportType,
    required this.selectedSections,
    required this.onSelectionChanged,
  });

  final ReportExportType reportType;
  final Set<String> selectedSections;
  final ValueChanged<Set<String>> onSelectionChanged;

  List<ReportExportSection> get sections =>
      reportType.sections;

  bool get allSelected =>
      selectedSections.length == sections.length;

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
            'Select which sections to include in the export.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _SelectionTile(
            label: 'Select All',
            selected: allSelected,
            highlighted: true,
            onTap: _toggleAll,
          ),
          const SizedBox(height: 10),
          ...sections.map(
                (section) => Padding(
              padding: const EdgeInsets.only(
                bottom: 9,
              ),
              child: _SelectionTile(
                label: section.label,
                selected:
                selectedSections.contains(section.id),
                highlighted:
                selectedSections.contains(section.id),
                onTap: () => _toggleSection(section),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAll() {
    if (allSelected) {
      onSelectionChanged(<String>{});
      return;
    }

    onSelectionChanged(
      sections.map((section) => section.id).toSet(),
    );
  }

  void _toggleSection(
      ReportExportSection section,
      ) {
    final updated =
    Set<String>.from(selectedSections);

    if (updated.contains(section.id)) {
      updated.remove(section.id);
    } else {
      updated.add(section.id);
    }

    onSelectionChanged(updated);
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.radiusMD,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMD,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF1D2A1B)
                : AppColors.background,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: highlighted
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: selected
                    ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.black,
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
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