import '../entities/downloadable_report.dart';
import '../entities/report_export_request.dart';
import '../entities/report_export_result.dart';
import '../entities/report_membership_breakdown.dart';
import '../entities/report_peak_hour.dart';
import '../entities/report_summary.dart';
import '../entities/report_trend.dart';

abstract class ReportRepository {
  Future<ReportSummary> getSummary({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<ReportTrend>> getTrends({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<ReportPeakHour>> getPeakHours({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<ReportMembershipBreakdown>>
  getMembershipBreakdown({
    required String gymId,
  });

  Future<List<DownloadableReport>>
  getDownloadableReports();

  /// Legacy method can remain for now if other UI still uses it.
  Future<String> exportReportCsv({
    required DownloadableReportType type,
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// New real export pipeline.
  Future<ReportExportResult> exportReport({
    required ReportExportRequest request,
  });
}