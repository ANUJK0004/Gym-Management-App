import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'report_export_sheet.dart';

class ReportExportSuccessSheet extends StatefulWidget {
  const ReportExportSuccessSheet({
    super.key,
    required this.result,
    required this.onDone,
  });

  final ReportExportResult result;
  final VoidCallback onDone;

  @override
  State<ReportExportSuccessSheet> createState() =>
      _ReportExportSuccessSheetState();
}

class _ReportExportSuccessSheetState
    extends State<ReportExportSuccessSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          widget.onDone();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF294725),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Report Exported!',
              style:
              AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 9),
            Text(
              'Your ${widget.result.reportType.label} '
                  'report has been generated as '
                  '${widget.result.format.label} '
                  'for ${widget.result.period.label}.',
              textAlign: TextAlign.center,
              style:
              AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color:
                const Color(0xFF294725),
                borderRadius:
                BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary
                      .withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ready to download',
                    style:
                    AppTextStyles.labelMedium.copyWith(
                      color:
                      AppColors.primary,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}