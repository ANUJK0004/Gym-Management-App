import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/report_peak_hour.dart';

class ReportPeakHoursCard extends StatelessWidget {
  const ReportPeakHoursCard({
    super.key,
    required this.hours,
  });

  final List<ReportPeakHour> hours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peak Hours',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (hours.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Attendance data will appear here after the Attendance feature is added.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 145,
              child: _PeakHoursChart(hours: hours),
            ),
        ],
      ),
    );
  }
}

class _PeakHoursChart extends StatelessWidget {
  const _PeakHoursChart({
    required this.hours,
  });

  final List<ReportPeakHour> hours;

  @override
  Widget build(BuildContext context) {
    final maxSessions = hours
        .map((item) => item.sessions)
        .fold<int>(1, mathMax);

    final visible = hours.take(9).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: visible.map((item) {
        final factor = item.sessions / maxSessions;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: factor.clamp(.05, 1),
                      widthFactor: .72,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _barColor(item, maxSessions),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _hourLabel(item.hour),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  int mathMax(int a, int b) => a > b ? a : b;

  Color _barColor(ReportPeakHour hour, int maxSessions) {
    final ratio = maxSessions == 0
        ? 0
        : hour.sessions / maxSessions;

    if (ratio > .75) {
      return AppColors.primary;
    }

    if (ratio > .5) {
      return AppColors.primary.withValues(alpha: .6);
    }

    return AppColors.border;
  }

  String _hourLabel(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final normalized = hour % 12 == 0 ? 12 : hour % 12;
    return '$normalized$period';
  }
}
