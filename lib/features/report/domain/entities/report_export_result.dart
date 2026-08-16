import 'report_export_request.dart';

class ReportExportResult {
  const ReportExportResult({
    required this.downloadUrl,
    required this.fileName,
    required this.format,
    required this.type,
    required this.periodLabel,
    required this.expiresAt,
    required this.emailSent,
    this.email,
  });

  final String downloadUrl;

  final String fileName;

  final ReportExportFormat format;

  final ReportExportType type;

  final String periodLabel;

  final DateTime expiresAt;

  final bool emailSent;

  final String? email;

  bool get hasEmail => email != null && email!.isNotEmpty;
}