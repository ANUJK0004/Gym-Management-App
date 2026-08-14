import 'downloadable_report.dart';
import 'report_membership_breakdown.dart';
import 'report_peak_hour.dart';
import 'report_trend.dart';

class ReportSummary {
  const ReportSummary({
    required this.churnRate,
    required this.churnChange,
    required this.lifetimeValue,
    required this.lifetimeValueChange,
    required this.averageSessions,
    required this.averageSessionsChange,
    required this.npsScore,
    required this.npsChange,
  });

  final double churnRate;
  final double churnChange;
  final double lifetimeValue;
  final double lifetimeValueChange;
  final num averageSessions;
  final num averageSessionsChange;
  final double npsScore;
  final double npsChange;
}

class ReportDashboardData {
  const ReportDashboardData({
    required this.summary,
    required this.trends,
    required this.peakHours,
    required this.membershipBreakdown,
    required this.downloadableReports,
  });

  final ReportSummary summary;
  final List<ReportTrend> trends;
  final List<ReportPeakHour> peakHours;
  final List<ReportMembershipBreakdown> membershipBreakdown;
  final List<DownloadableReport> downloadableReports;
}
