import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

class FinanceExportSuccessSheet
    extends StatefulWidget {
  const FinanceExportSuccessSheet({
    super.key,
    required this.format,
    required this.emailed,
  });

  final String format;
  final bool emailed;

  @override
  State<FinanceExportSuccessSheet>
  createState() =>
      _FinanceExportSuccessSheetState();
}

class _FinanceExportSuccessSheetState
    extends State<FinanceExportSuccessSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(
        seconds: 3,
      ),
          () {
        if (mounted) {
          Navigator.of(context).pop();
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
  Widget build(
      BuildContext context,
      ) {
    final title =
    widget.emailed
        ? 'Finance Report Sent!'
        : 'Finance Exported!';

    final description =
    widget.emailed
        ? 'Your Finance report has been generated successfully as '
        '${widget.format} and sent to the provided email address.'
        : 'Your Finance report has been generated successfully as '
        '${widget.format}.';

    return SafeArea(
      top: false,
      child: Container(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        decoration:
        const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.vertical(
            top:
            Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration:
              BoxDecoration(
                color:
                AppColors.textHint,
                borderRadius:
                AppRadius.circularRadius,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Container(
              width: 72,
              height: 72,
              decoration:
              BoxDecoration(
                color:
                AppColors.primary
                    .withOpacity(
                  0.18,
                ),
                borderRadius:
                BorderRadius.circular(
                  22,
                ),
              ),
              child:
              const Icon(
                Icons.check_rounded,
                size: 42,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              title,
              style:
              AppTextStyles.titleLarge
                  .copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              description,
              textAlign:
              TextAlign.center,
              style:
              AppTextStyles.bodyMedium
                  .copyWith(
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration:
              BoxDecoration(
                color: AppColors.primary
                    .withOpacity(
                  0.10,
                ),
                borderRadius:
                AppRadius.radiusSM,
                border: Border.all(
                  color: AppColors.primary
                      .withOpacity(
                    0.35,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    widget.emailed
                        ? Icons
                        .email_outlined
                        : Icons
                        .download_rounded,
                    size: 15,
                    color:
                    AppColors.primary,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    widget.emailed
                        ? 'Sent by email'
                        : 'Ready to download',
                    style:
                    AppTextStyles
                        .labelMedium
                        .copyWith(
                      fontSize: 11,
                      color:
                      AppColors.primary,
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