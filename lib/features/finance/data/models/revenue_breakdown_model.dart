import '../../domain/entities/revenue_breakdown.dart';

class RevenueBreakdownModel
    extends RevenueBreakdown {
  const RevenueBreakdownModel({
    required super.category,
    required super.amount,
    required super.percentage,
  });

  factory RevenueBreakdownModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return RevenueBreakdownModel(
      category:
      data['category'] as String? ?? '',

      amount:
      (data['amount'] as num?)?.toDouble() ?? 0,

      percentage:
      (data['percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'percentage': percentage,
    };
  }
}