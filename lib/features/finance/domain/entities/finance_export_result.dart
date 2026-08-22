class FinanceExportResult {
  const FinanceExportResult({
    required this.success,
    required this.fileName,
    required this.format,
    required this.downloadUrl,
    required this.emailed,
    this.email,
    this.message,
  });

  final bool success;

  final String fileName;

  final String format;

  /// Temporary signed URL.
  ///
  /// May be null when the email delivery succeeds
  /// and a direct download URL is not required.
  final String? downloadUrl;

  final bool emailed;

  final String? email;

  final String? message;

  bool get hasDownloadUrl =>
      downloadUrl != null &&
          downloadUrl!.trim().isNotEmpty;
}