import '../../domain/entities/report_summary.dart';

class ReportSummaryModel extends ReportSummary {
  const ReportSummaryModel({
    required super.churnRate,
    required super.churnChange,
    required super.lifetimeValue,
    required super.lifetimeValueChange,
    required super.averageSessions,
    required super.averageSessionsChange,
    required super.npsScore,
    required super.npsChange,
  });

  factory ReportSummaryModel.fromMap(
      Map<String, dynamic> data) {
    return ReportSummaryModel(
      churnRate:
          (data['churnRate'] as num?)?.toDouble() ?? 0,
      churnChange:
          (data['churnChange'] as num?)?.toDouble() ?? 0,
      lifetimeValue:
          (data['lifetimeValue'] as num?)?.toDouble() ?? 0,
      lifetimeValueChange:
          (data['lifetimeValueChange'] as num?)
                  ?.toDouble() ??
              0,
      averageSessions:
          (data['averageSessions'] as num?)?.toDouble() ?? 0,
      averageSessionsChange:
          (data['averageSessionsChange'] as num?)
                  ?.toDouble() ??
              0,
      npsScore:
          (data['npsScore'] as num?)?.toDouble() ?? 0,
      npsChange:
          (data['npsChange'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'churnRate': churnRate,
      'churnChange': churnChange,
      'lifetimeValue': lifetimeValue,
      'lifetimeValueChange': lifetimeValueChange,
      'averageSessions': averageSessions,
      'averageSessionsChange': averageSessionsChange,
      'npsScore': npsScore,
      'npsChange': npsChange,
    };
  }
}
