enum DownloadableReportType {
  monthlyRevenue,
  memberAcquisition,
  trainerPerformance,
  attendanceAnalytics,
}

class DownloadableReport {
  const DownloadableReport({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final DownloadableReportType type;
  final String title;
  final String subtitle;
  final String icon;
}
