import '../../domain/entities/report_trend.dart';

class ReportTrendPointModel extends ReportTrendPoint {
  const ReportTrendPointModel({
    required super.month,
    required super.value,
  });

  factory ReportTrendPointModel.fromMap(
      Map<String, dynamic> data) {
    return ReportTrendPointModel(
      month: data['month'] as String? ?? '',
      value: (data['value'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'value': value,
    };
  }
}

class ReportTrendModel extends ReportTrend {
  const ReportTrendModel({
    required super.type,
    required super.points,
    required super.currentValue,
    required super.changeFromStart,
  });

  factory ReportTrendModel.fromMap(
      Map<String, dynamic> data) {
    final rawType = data['type'] as String? ?? 'members';
    final type = rawType == 'retention'
        ? ReportTrendType.retention
        : ReportTrendType.members;

    final rawPoints =
        (data['points'] as List<dynamic>? ?? const []);

    return ReportTrendModel(
      type: type,
      points: rawPoints
          .whereType<Map>()
          .map(
            (point) => ReportTrendPointModel.fromMap(
              Map<String, dynamic>.from(point),
            ),
          )
          .toList(),
      currentValue:
          (data['currentValue'] as num?)?.toDouble() ?? 0,
      changeFromStart:
          (data['changeFromStart'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'points': points
          .map(
            (point) => {
              'month': point.month,
              'value': point.value,
            },
          )
          .toList(),
      'currentValue': currentValue,
      'changeFromStart': changeFromStart,
    };
  }
}
