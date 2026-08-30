import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/downloadable_report.dart';

class DownloadableReportCard extends StatelessWidget {
  const DownloadableReportCard({
    super.key,
    required this.report,
    required this.onDownload,
  });

  final DownloadableReport report;
  final Future<void> Function(DownloadableReport report) onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.owner.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              report.icon,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.subtitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.owner.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: () => onDownload(report),
              borderRadius: BorderRadius.circular(9),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: AppColors.owner,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
