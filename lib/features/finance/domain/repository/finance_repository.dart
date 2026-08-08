import '../entities/finance_transaction.dart';
import '../entities/revenue_breakdown.dart';
import '../entities/revenue_trend.dart';

abstract class FinanceRepository {
  Future<List<FinanceTransaction>>
  getTransactions({
    required String gymId,
    int limit = 20,
  });

  Future<List<RevenueBreakdown>>
  getRevenueBreakdown({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<RevenueTrend>>
  getRevenueTrend({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void>
  createTransaction(
      FinanceTransaction transaction,
  );
}