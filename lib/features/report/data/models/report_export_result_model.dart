import '../../domain/entities/report_export_request.dart';
import '../../domain/entities/report_export_result.dart';

class ReportExportResultModel extends ReportExportResult {
  const ReportExportResultModel({
    required super.downloadUrl,
    required super.fileName,
    required super.format,
    required super.type,
    required super.periodLabel,
    required super.expiresAt,
    required super.emailSent,
    super.email,
  });

  factory ReportExportResultModel.fromMap(
      Map<String, dynamic> data,
      ) {
    final formatString =
        data['format'] as String? ?? 'pdf';

    final typeString =
        data['reportType'] as String? ?? 'full';

    final expiresString =
    data['expiresAt'] as String?;

    return ReportExportResultModel(
      downloadUrl:
      data['downloadUrl'] as String? ?? '',
      fileName:
      data['fileName'] as String? ?? '',
      format:
      ReportExportFormat.values.firstWhere(
            (value) => value.name == formatString,
        orElse: () =>
        ReportExportFormat.pdf,
      ),
      type:
      ReportExportType.values.firstWhere(
            (value) => value.name == typeString,
        orElse: () =>
        ReportExportType.full,
      ),
      periodLabel:
      data['periodLabel'] as String? ?? '',
      expiresAt:
      expiresString != null
          ? DateTime.tryParse(expiresString) ??
          DateTime.now()
          : DateTime.now(),
      emailSent:
      data['emailSent'] as bool? ?? false,
      email:
      data['email'] as String?,
    );
  }
}