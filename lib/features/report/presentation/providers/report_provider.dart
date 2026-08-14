import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gym/presentation/providers/gym_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/downloadable_report.dart';
import '../../domain/entities/report_membership_breakdown.dart';
import '../../domain/entities/report_peak_hour.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/report_trend.dart';
import '../../domain/repositories/report_repository.dart';

final reportFirestoreProvider =
    Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final reportRemoteDataSourceProvider =
    Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource(
    ref.watch(reportFirestoreProvider),
  );
});

final reportRepositoryProvider =
    Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    ref.watch(reportRemoteDataSourceProvider),
  );
});

final reportSummaryProvider =
    FutureProvider<ReportSummary>((ref) async {
  final gym = await ref.watch(ownerGymProvider.future);

  if (gym == null) {
    return const ReportSummary(
      churnRate: 0,
      churnChange: 0,
      lifetimeValue: 0,
      lifetimeValueChange: 0,
      averageSessions: 0,
      averageSessionsChange: 0,
      npsScore: 0,
      npsChange: 0,
    );
  }

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1);

  return ref.watch(reportRepositoryProvider).getSummary(
        gymId: gym.id,
        startDate: startDate,
        endDate: endDate,
      );
});

final reportTrendsProvider =
    FutureProvider<List<ReportTrend>>((ref) async {
  final gym = await ref.watch(ownerGymProvider.future);

  if (gym == null) {
    return [];
  }

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month - 11, 1);
  final endDate = DateTime(now.year, now.month + 1, 1);

  return ref.watch(reportRepositoryProvider).getTrends(
        gymId: gym.id,
        startDate: startDate,
        endDate: endDate,
      );
});

final reportPeakHoursProvider =
    FutureProvider<List<ReportPeakHour>>((ref) async {
  final gym = await ref.watch(ownerGymProvider.future);

  if (gym == null) {
    return [];
  }

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 1);

  return ref.watch(reportRepositoryProvider).getPeakHours(
        gymId: gym.id,
        startDate: startDate,
        endDate: endDate,
      );
});

final reportMembershipBreakdownProvider =
    FutureProvider<List<ReportMembershipBreakdown>>(
        (ref) async {
  final gym = await ref.watch(ownerGymProvider.future);

  if (gym == null) {
    return [];
  }

  return ref
      .watch(reportRepositoryProvider)
      .getMembershipBreakdown(
        gymId: gym.id,
      );
});

final downloadableReportsProvider =
    FutureProvider<List<DownloadableReport>>((ref) async {
  return ref
      .watch(reportRepositoryProvider)
      .getDownloadableReports();
});

final reportDashboardDataProvider =
    FutureProvider<ReportDashboardData>((ref) async {
  final results = await Future.wait([
    ref.watch(reportSummaryProvider.future),
    ref.watch(reportTrendsProvider.future),
    ref.watch(reportPeakHoursProvider.future),
    ref.watch(reportMembershipBreakdownProvider.future),
    ref.watch(downloadableReportsProvider.future),
  ]);

  return ReportDashboardData(
    summary: results[0] as ReportSummary,
    trends: results[1] as List<ReportTrend>,
    peakHours: results[2] as List<ReportPeakHour>,
    membershipBreakdown:
        results[3] as List<ReportMembershipBreakdown>,
    downloadableReports:
        results[4] as List<DownloadableReport>,
  );
});

String reportPeriodLabel() {
  final now = DateTime.now();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[now.month - 1]} ${now.year}';
}
