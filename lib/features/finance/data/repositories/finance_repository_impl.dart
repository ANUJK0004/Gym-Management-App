import '../../domain/entities/finance_transaction.dart';
import '../../domain/entities/revenue_breakdown.dart';
import '../../domain/entities/revenue_trend.dart';
import '../../domain/repository/finance_repository.dart';
import '../datasources/finance_remote_datasources.dart';


class FinanceRepositoryImpl
    implements FinanceRepository {
  FinanceRepositoryImpl(
      this._dataSource,
      );

  final FinanceRemoteDataSource _dataSource;

  @override
  Future<List<FinanceTransaction>>
  getTransactions({
    required String gymId,
    int limit = 20,
  }) {
    return _dataSource.getTransactions(
      gymId: gymId,
      limit: limit,
    );
  }

  @override
  Future<List<RevenueBreakdown>>
  getRevenueBreakdown({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions =
    await _dataSource.getTransactions(
      gymId: gymId,
      limit: 1000,
    );

    final filtered =
    transactions.where(
          (transaction) {
        return transaction.isIncome &&
            !transaction.date
                .isBefore(startDate) &&
            transaction.date
                .isBefore(endDate);
      },
    );

    final Map<String, double>
    categoryTotals = {};

    for (final transaction
    in filtered) {
      final category =
          transaction.category ??
              'Other';

      categoryTotals[category] =
          (categoryTotals[category] ??
              0) +
              transaction.amount;
    }

    final total =
    categoryTotals.values.fold<double>(
      0,
          (sum, value) =>
      sum + value,
    );

    if (total == 0) {
      return [];
    }

    return categoryTotals.entries
        .map(
          (entry) {
        return RevenueBreakdown(
          category:
          entry.key,
          amount:
          entry.value,
          percentage:
          entry.value /
              total *
              100,
        );
      },
    )
        .toList()
      ..sort(
            (a, b) =>
            b.amount.compareTo(
              a.amount,
            ),
      );
  }

  @override
  Future<List<RevenueTrend>>
  getRevenueTrend({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions =
    await _dataSource.getTransactions(
      gymId: gymId,
      limit: 1000,
    );

    final Map<int, double>
    monthlyTotals = {};

    for (final transaction
    in transactions) {
      if (!transaction.isIncome) {
        continue;
      }

      if (transaction.date
          .isBefore(startDate) ||
          !transaction.date
              .isBefore(endDate)) {
        continue;
      }

      final month =
          transaction.date.month;

      monthlyTotals[month] =
          (monthlyTotals[month] ??
              0) +
              transaction.amount;
    }

    final monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return monthlyTotals.entries
        .map(
          (entry) {
        return RevenueTrend(
          month:
          monthLabels[
          entry.key - 1],
          amount:
          entry.value,
        );
      },
    )
        .toList()
      ..sort(
            (a, b) =>
        monthLabels.indexOf(
          a.month,
        ) -
            monthLabels.indexOf(
              b.month,
            ),
      );
  }
}