enum ReportTrendType {
  members,
  retention,
}

class ReportTrendPoint {
  const ReportTrendPoint({
    required this.month,
    required this.value,
  });

  final String month;
  final num value;
}

class ReportTrend {
  const ReportTrend({
    required this.type,
    required this.points,
    required this.currentValue,
    required this.changeFromStart,
  });

  final ReportTrendType type;
  final List<ReportTrendPoint> points;
  final num currentValue;
  final num changeFromStart;
}
