enum ReportExportType {
  finance,
  members,
  staff,
  operations,
  full,
}

enum ReportExportFormat {
  pdf,
  excel,
  csv,
}

enum ReportExportPeriod {
  thisWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
}

class ReportExportRequest {
  const ReportExportRequest({
    required this.type,
    required this.sections,
    required this.format,
    required this.period,
    this.email,
  });

  final ReportExportType type;

  /// IDs selected in the export-content step.
  ///
  /// Examples:
  /// trainerSessions
  /// clientRatings
  /// attendanceRate
  /// performanceScores
  /// revenue
  /// expenses
  /// members
  /// retention
  final List<String> sections;

  final ReportExportFormat format;

  final ReportExportPeriod period;

  /// Optional delivery email.
  ///
  /// null/empty means:
  /// generate → storage → download URL only.
  final String? email;

  bool get hasEmail =>
      email != null &&
          email!.trim().isNotEmpty;
}