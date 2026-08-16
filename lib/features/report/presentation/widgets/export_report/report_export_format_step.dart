import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../domain/entities/report_export_request.dart';
import 'report_export_sheet.dart';

class ReportExportFormatStep extends StatelessWidget {
  const ReportExportFormatStep({
    super.key,
    required this.reportType,
    required this.selectedSectionCount,
    required this.selectedFormat,
    required this.selectedPeriod,
    required this.emailController,
    required this.onFormatChanged,
    required this.onPeriodChanged,
  });

  final ReportExportType reportType;
  final int selectedSectionCount;
  final ReportExportFormat selectedFormat;
  final ReportExportPeriod selectedPeriod;
  final TextEditingController emailController;
  final ValueChanged<ReportExportFormat> onFormatChanged;
  final ValueChanged<ReportExportPeriod> onPeriodChanged;

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
          _sectionLabel('EXPORT SUMMARY'),
          const SizedBox(height: 8),
          _summaryCard(),
          const SizedBox(height: 18),
          _sectionLabel('FILE FORMAT'),
          const SizedBox(height: 9),
          Row(
            children: ReportExportFormat.values.map(
                  (format) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: format ==
                          ReportExportFormat.values.last
                          ? 0
                          : 8,
                    ),
                    child: _FormatCard(
                      format: format,
                      selected:
                      selectedFormat == format,
                      onTap: () =>
                          onFormatChanged(format),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 18),
          _sectionLabel('TIME PERIOD'),
          const SizedBox(height: 9),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.1,
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            children:
            ReportExportPeriod.values.map(
                  (period) {
                final selected =
                    selectedPeriod == period;

                return Material(
                  color: Colors.transparent,
                  borderRadius:
                  AppRadius.radiusMD,
                  child: InkWell(
                    onTap: () =>
                        onPeriodChanged(period),
                    borderRadius:
                    AppRadius.radiusMD,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1D2A1B)
                            : AppColors.background,
                        borderRadius:
                        AppRadius.radiusMD,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        period.label,
                        style:
                        AppTextStyles.labelMedium
                            .copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                          selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 18),
          _sectionLabel(
            'EMAIL DELIVERY (OPTIONAL)',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            keyboardType:
            TextInputType.emailAddress,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: 'admin@gymsync.com',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                AppRadius.radiusMD,
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                AppRadius.radiusMD,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Leave blank to download directly.',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Report Type',
            value: reportType.label,
          ),
          const SizedBox(height: 9),
          _SummaryRow(
            label: 'Sections',
            value:
            '$selectedSectionCount selected',
            valueColor:
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 9,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color:
            valueColor ?? AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.format,
    required this.selected,
    required this.onTap,
  });

  final ReportExportFormat format;
  final bool selected;
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
          duration: const Duration(
            milliseconds: 120,
          ),
          height: 92,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1D2A1B)
                : AppColors.background,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Text(
                format.icon,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                format.label,
                style:
                AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                format.subtitle,
                textAlign: TextAlign.center,
                style:
                AppTextStyles.labelMedium.copyWith(
                  color:
                  AppColors.textSecondary,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}