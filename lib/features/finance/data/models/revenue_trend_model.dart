import '../../domain/entities/revenue_trend.dart';

class RevenueTrendModel
    extends RevenueTrend {
  const RevenueTrendModel({
    required super.month,
    required super.amount,
  });

  factory RevenueTrendModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return RevenueTrendModel(
      month:
      data['month'] as String? ?? '',

      amount:
      (data['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'amount': amount,
    };
  }
}