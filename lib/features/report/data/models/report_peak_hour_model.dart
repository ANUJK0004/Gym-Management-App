import '../../domain/entities/report_peak_hour.dart';

class ReportPeakHourModel extends ReportPeakHour {
  const ReportPeakHourModel({
    required super.hour,
    required super.sessions,
  });

  factory ReportPeakHourModel.fromMap(
      Map<String, dynamic> data) {
    return ReportPeakHourModel(
      hour: (data['hour'] as num?)?.toInt() ?? 0,
      sessions: (data['sessions'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'sessions': sessions,
    };
  }
}
