import '../../domain/entities/finance_export_result.dart';

class FinanceExportResultModel
    extends FinanceExportResult {
  const FinanceExportResultModel({
    required super.success,
    required super.fileName,
    required super.format,
    required super.downloadUrl,
    required super.emailed,
    super.email,
    super.message,
  });

  factory FinanceExportResultModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return FinanceExportResultModel(
      success:
      data['success'] as bool? ?? false,

      fileName:
      data['fileName'] as String? ?? '',

      format:
      data['format'] as String? ?? '',

      downloadUrl:
      data['downloadUrl'] as String?,

      emailed:
      data['emailed'] as bool? ?? false,

      email:
      data['email'] as String?,

      message:
      data['message'] as String?,
    );
  }
}