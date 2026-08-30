import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';

import '../../domain/entities/downloadable_report.dart';
import '../../domain/entities/report_export_request.dart';
import '../../domain/entities/report_summary.dart';

import '../providers/report_provider.dart';

import '../widgets/downloadable_report_card.dart';
import '../widgets/export_report/report_export_sheet.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_membership_breakdown.dart';
import '../widgets/report_metric_card.dart';
import '../widgets/report_peak_hours_card.dart';
import '../widgets/report_trend_card.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final dashboardAsync =
    ref.watch(reportDashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.owner,
          onRefresh: () async {
            ref.invalidate(
              reportDashboardDataProvider,
            );

            await ref.read(
              reportDashboardDataProvider.future,
            );
          },
          child: dashboardAsync.when(
            loading: () {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
                ),
              );
            },
            error: (
                error,
                stackTrace,
                ) {
              return _ErrorView(
                error: error,
                onRetry: () {
                  ref.invalidate(
                    reportDashboardDataProvider,
                  );
                },
              );
            },
            data: (dashboard) {
              return _ReportContent(
                dashboard: dashboard,
                onExport: () {
                  _showExportPicker(context);
                },
                onDownloadReport: (report) {
                  return _exportReport(
                    context,
                    ref,
                    report,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showExportPicker(
      BuildContext context,
      ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      useSafeArea: true,
      builder: (_) {
        return const ReportExportSheet();
      },
    );
  }

  Future<void> _exportReport(
      BuildContext context,
      WidgetRef ref,
      DownloadableReport report,
      ) async {
    try {
      final request = _buildDownloadRequest(
        report,
      );

      final result = await ref
          .read(
        reportExportControllerProvider
            .notifier,
      )
          .export(request);

      if (!context.mounted) {
        return;
      }

      final uri = Uri.tryParse(
        result.downloadUrl,
      );

      if (uri == null) {
        throw Exception(
          'Invalid download URL.',
        );
      }

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception(
          'Unable to open the report.',
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(
              seconds: 3,
            ),
            content: Text(
              _friendlyExportError(error),
            ),
          ),
        );
    }
  }

  ReportExportRequest _buildDownloadRequest(
      DownloadableReport report,
      ) {
    switch (report.type) {
      case DownloadableReportType.monthlyRevenue:
        return const ReportExportRequest(
          type: ReportExportType.finance,
          sections: [
            'revenue',
          ],
          format: ReportExportFormat.csv,
          period: ReportExportPeriod.thisMonth,
        );

      case DownloadableReportType.memberAcquisition:
        return const ReportExportRequest(
          type: ReportExportType.members,
          sections: [
            'enrollment',
          ],
          format: ReportExportFormat.csv,
          period: ReportExportPeriod.thisYear,
        );

      case DownloadableReportType.trainerPerformance:
        return const ReportExportRequest(
          type: ReportExportType.staff,
          sections: [
            'trainer_sessions',
            'client_ratings',
            'performance_scores',
          ],
          format: ReportExportFormat.csv,
          period: ReportExportPeriod.thisYear,
        );

      case DownloadableReportType.attendanceAnalytics:
        return const ReportExportRequest(
          type: ReportExportType.operations,
          sections: [
            'attendance_rate',
            'peak_hours',
          ],
          format: ReportExportFormat.csv,
          period: ReportExportPeriod.thisMonth,
        );
    }
  }

  String _friendlyExportError(
      Object error,
      ) {
    final message = error.toString();

    if (message.contains('email')) {
      return 'The report email could not be processed.';
    }

    if (message.contains('permission-denied') ||
        message.contains('permission')) {
      return 'You do not have permission to export this report.';
    }

    if (message.contains('unauthenticated')) {
      return 'Your session has expired. Please sign in again.';
    }

    return 'Unable to export report. Please try again.';
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({
    required this.dashboard,
    required this.onExport,
    required this.onDownloadReport,
  });

  final ReportDashboardData dashboard;

  final VoidCallback onExport;

  final Future<void> Function(
      DownloadableReport report,
      ) onDownloadReport;

  @override
  Widget build(
      BuildContext context,
      ) {
    final summary = dashboard.summary;

    return CustomScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            14,
            18,
            14,
            40,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _Header(
                onExport: onExport,
              ),

              const SizedBox(
                height: 20,
              ),

              _SectionTitle(
                title:
                'ANALYTICS · ${reportPeriodLabel()}',
              ),

              const SizedBox(
                height: 10,
              ),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                children: [
                  ReportMetricCard(
                    icon:
                    Icons.mark_email_unread_outlined,
                    value:
                    '${summary.churnRate.toStringAsFixed(1)}%',
                    label: 'Churn Rate',
                    change: _signed(
                      summary.churnChange,
                      suffix: '%',
                    ),
                    changePositiveIsGood:
                    false,
                  ),

                  ReportMetricCard(
                    icon:
                    Icons.diamond_outlined,
                    value: _rupees(
                      summary.lifetimeValue,
                    ),
                    label: 'LTV / Member',
                    change: _signedRupees(
                      summary.lifetimeValueChange,
                    ),
                  ),

                  ReportMetricCard(
                    icon:
                    Icons.emoji_events_outlined,
                    value: summary.averageSessions
                        .toStringAsFixed(1),
                    label: 'Avg Sessions/mo',
                    change: _signed(
                      summary.averageSessionsChange,
                    ),
                  ),

                  ReportMetricCard(
                    icon: Icons.star_rounded,
                    value: summary.npsScore
                        .toStringAsFixed(0),
                    label: 'NPS Score',
                    change: _signed(
                      summary.npsChange.toDouble(),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              ReportTrendCard(
                trends: dashboard.trends,
              ),

              const SizedBox(
                height: 18,
              ),

              ReportPeakHoursCard(
                hours: dashboard.peakHours,
              ),

              const SizedBox(
                height: 18,
              ),

              ReportMembershipBreakdownWidget(
                items:
                dashboard.membershipBreakdown,
              ),

              const SizedBox(
                height: 20,
              ),

              _SectionTitle(
                title: 'DOWNLOADABLE REPORTS',
              ),

              const SizedBox(
                height: 10,
              ),

              ...dashboard.downloadableReports.map(
                    (report) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: DownloadableReportCard(
                    report: report,
                    onDownload:
                    onDownloadReport,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  String _signed(
      num value, {
        String suffix = '',
      }) {
    final prefix = value >= 0 ? '+' : '';

    return '$prefix${value.toStringAsFixed(1)}$suffix';
  }

  String _signedRupees(
      double value,
      ) {
    final prefix = value >= 0 ? '+' : '-';

    return '$prefix${_rupees(value.abs())}';
  }

  String _rupees(
      double value,
      ) {
    final rounded = value.round();

    if (rounded >= 100000) {
      return '₹${(rounded / 1000).toStringAsFixed(1)}K';
    }

    return '₹${_withCommas(rounded)}';
  }

  String _withCommas(
      int value,
      ) {
    final sign = value < 0 ? '-' : '';

    final digits = value.abs().toString();

    return sign +
        digits.replaceAllMapped(
          RegExp(
            r'(\d)(?=(\d{3})+(?!\d))',
          ),
              (match) => '${match[1]},',
        );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onExport,
  });

  final VoidCallback onExport;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        const AppBackButton(
          fallbackRoute: AppRoutes.ownerHome,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              Text(
                'Analytics & insights',
                style: AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        ReportExportButton(
          onPressed: onExport,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style:
        AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppColors.owner,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              'Unable to load reports.',
              style: AppTextStyles
                  .titleMedium
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles
                  .bodySmall
                  .copyWith(
                color:
                AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.owner,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}