import '../../domain/entities/downloadable_report.dart';

class DownloadableReportModel extends DownloadableReport {
  const DownloadableReportModel({
    required super.type,
    required super.title,
    required super.subtitle,
    required super.icon,
  });

  factory DownloadableReportModel.fromMap(
      Map<String, dynamic> data) {
    final typeValue = data['type'] as String? ?? '';

    final type = DownloadableReportType.values.firstWhere(
      (value) => value.name == typeValue,
      orElse: () => DownloadableReportType.monthlyRevenue,
    );

    return DownloadableReportModel(
      type: type,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      icon: data['icon'] as String? ?? '📄',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
    };
  }
}
