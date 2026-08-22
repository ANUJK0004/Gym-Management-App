import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import '../../../domain/entities/finance_export_request.dart';
import 'finance_export_format_selector.dart';
import 'finance_export_period_selector.dart';
import 'finance_export_section_selector.dart';

class FinanceExportSheet
    extends StatefulWidget {
  const FinanceExportSheet({
    super.key,
    required this.onExport,
  });

  final Future<void> Function(
      FinanceExportFormat format,
      FinanceExportPeriod period,
      Set<FinanceExportSection> sections,
      String? email,
      ) onExport;

  @override
  State<FinanceExportSheet> createState() =>
      _FinanceExportSheetState();
}

class _FinanceExportSheetState
    extends State<FinanceExportSheet> {
  final TextEditingController
  _emailController =
  TextEditingController();

  FinanceExportFormat _selectedFormat =
      FinanceExportFormat.pdf;

  FinanceExportPeriod _selectedPeriod =
      FinanceExportPeriod.lastMonth;

  Set<FinanceExportSection>
  _selectedSections = {
    FinanceExportSection.revenueSummary,
    FinanceExportSection.expenseBreakdown,
  };

  bool _exporting = false;

  String get _formatLabel {
    switch (_selectedFormat) {
      case FinanceExportFormat.pdf:
        return 'PDF';

      case FinanceExportFormat.excel:
        return 'Excel';

      case FinanceExportFormat.csv:
        return 'CSV';
    }
  }

  String get _exportButtonLabel {
    switch (_selectedFormat) {
      case FinanceExportFormat.pdf:
        return 'Export as PDF';

      case FinanceExportFormat.excel:
        return 'Export as Excel';

      case FinanceExportFormat.csv:
        return 'Export as CSV';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    if (_exporting ||
        _selectedSections.isEmpty) {
      return;
    }

    final email =
    _emailController.text.trim();

    setState(() {
      _exporting = true;
    });

    try {
      await widget.onExport(
        _selectedFormat,
        _selectedPeriod,
        _selectedSections,
        email.isEmpty ? null : email,
      );
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          19,
          10,
          19,
          16 + bottomInset,
        ),
        decoration:
        const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child:
        SingleChildScrollView(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const _DragHandle(),

              const SizedBox(
                height: 18,
              ),

              _SheetHeader(
                onClose: _exporting
                    ? null
                    : () =>
                    Navigator.of(
                      context,
                    ).pop(),
              ),

              const SizedBox(
                height: 20,
              ),

              FinanceExportFormatSelector(
                selectedFormat:
                _selectedFormat,
                onChanged:
                    (format) {
                  setState(() {
                    _selectedFormat =
                        format;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              FinanceExportPeriodSelector(
                selectedPeriod:
                _selectedPeriod,
                onChanged:
                    (period) {
                  setState(() {
                    _selectedPeriod =
                        period;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              FinanceExportSectionSelector(
                selectedSections:
                _selectedSections,
                onChanged:
                    (sections) {
                  setState(() {
                    _selectedSections =
                        sections;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              _EmailField(
                controller:
                _emailController,
              ),

              const SizedBox(
                height: 18,
              ),

              _ExportButton(
                label:
                _exportButtonLabel,
                loading:
                _exporting,
                enabled:
                _selectedSections
                    .isNotEmpty,
                onPressed:
                _handleExport,
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                '${_selectedSections.length} section'
                    '${_selectedSections.length == 1 ? '' : 's'} selected • '
                    '$_formatLabel',
                style:
                AppTextStyles.caption
                    .copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DRAG HANDLE
// ============================================================

class _DragHandle
    extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: 38,
      height: 4,
      decoration:
      BoxDecoration(
        color:
        AppColors.textHint,
        borderRadius:
        AppRadius.circularRadius,
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _SheetHeader
    extends StatelessWidget {
  const _SheetHeader({
    required this.onClose,
  });

  final VoidCallback? onClose;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Export Finance Report',
            style:
            AppTextStyles.titleMedium
                .copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),

        Material(
          color:
          AppColors.card,
          borderRadius:
          BorderRadius.circular(
            50,
          ),
          child: InkWell(
            onTap: onClose,
            borderRadius:
            BorderRadius.circular(
              50,
            ),
            child:
            const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                Icons.close_rounded,
                size: 17,
                color:
                AppColors
                    .textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EMAIL
// ============================================================

class _EmailField
    extends StatelessWidget {
  const _EmailField({
    required this.controller,
  });

  final TextEditingController
  controller;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL REPORT',
          style:
          AppTextStyles.labelMedium
              .copyWith(
            color:
            AppColors
                .textSecondary,
            fontSize: 10,
            fontWeight:
            FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextField(
          controller:
          controller,
          keyboardType:
          TextInputType.emailAddress,
          style:
          AppTextStyles.bodyMedium
              .copyWith(
            color:
            AppColors
                .textPrimary,
          ),
          decoration:
          InputDecoration(
            hintText:
            'Optional — leave empty to download',
            hintStyle:
            AppTextStyles
                .caption
                .copyWith(
              fontSize: 11,
            ),
            prefixIcon:
            const Icon(
              Icons.email_outlined,
              size: 18,
              color:
              AppColors
                  .textSecondary,
            ),
            filled: true,
            fillColor:
            AppColors.background,
            contentPadding:
            const EdgeInsets
                .symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              AppRadius.radiusMD,
              borderSide:
              const BorderSide(
                color:
                AppColors.border,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              AppRadius.radiusMD,
              borderSide:
              const BorderSide(
                color:
                AppColors.primary,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          'Leave this empty to open the generated file directly.',
          style:
          AppTextStyles.caption
              .copyWith(
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EXPORT BUTTON
// ============================================================

class _ExportButton
    extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(
      BuildContext context,
      ) {
    final active =
        enabled && !loading;

    return Material(
      color:
      active
          ? AppColors.primary
          : AppColors.card,
      borderRadius:
      AppRadius.radiusSM,
      child: InkWell(
        onTap:
        active
            ? onPressed
            : null,
        borderRadius:
        AppRadius.radiusSM,
        child: SizedBox(
          width:
          double.infinity,
          height: 44,
          child: Center(
            child: loading
                ? const SizedBox(
              width: 19,
              height: 19,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                AppColors
                    .textInverse,
              ),
            )
                : Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .download_rounded,
                  size: 17,
                  color:
                  AppColors
                      .textInverse,
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  label,
                  style:
                  AppTextStyles
                      .labelLarge
                      .copyWith(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}