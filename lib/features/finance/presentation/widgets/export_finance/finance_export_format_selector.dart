import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import '../../../domain/entities/finance_export_request.dart';

class FinanceExportFormatSelector extends StatelessWidget {
  const FinanceExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  final FinanceExportFormat selectedFormat;
  final ValueChanged<FinanceExportFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ExportSectionLabel(
          title: 'FORMAT',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FormatButton(
                icon: '📄',
                title: 'PDF',
                format: FinanceExportFormat.pdf,
                selectedFormat: selectedFormat,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FormatButton(
                icon: '📊',
                title: 'Excel',
                format: FinanceExportFormat.excel,
                selectedFormat: selectedFormat,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FormatButton(
                icon: '📋',
                title: 'CSV',
                format: FinanceExportFormat.csv,
                selectedFormat: selectedFormat,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.icon,
    required this.title,
    required this.format,
    required this.selectedFormat,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final FinanceExportFormat format;
  final FinanceExportFormat selectedFormat;
  final ValueChanged<FinanceExportFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = format == selectedFormat;

    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.inputField,
      borderRadius: AppRadius.radiusSM,
      child: InkWell(
        borderRadius: AppRadius.radiusSM,
        onTap: () => onChanged(format),
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportSectionLabel extends StatelessWidget {
  const _ExportSectionLabel({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textHint,
      ),
    );
  }
}