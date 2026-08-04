import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/finance_remote_datasources.dart';
import '../../data/repositories/finance_repository_impl.dart';

import '../../domain/entities/finance_transaction.dart';
import '../../domain/entities/revenue_breakdown.dart';
import '../../domain/entities/revenue_trend.dart';
import '../../domain/repository/finance_repository.dart';

final financeRemoteDataSourceProvider =
Provider<FinanceRemoteDataSource>(
      (ref) {
    return FinanceRemoteDataSource(
      FirebaseFirestore.instance,
    );
  },
);

final financeRepositoryProvider =
Provider<FinanceRepository>(
      (ref) {
    return FinanceRepositoryImpl(
      ref.watch(
        financeRemoteDataSourceProvider,
      ),
    );
  },
);

final financeTransactionsProvider =
FutureProvider<
    List<FinanceTransaction>>(
      (ref) async {
    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    return ref
        .watch(
      financeRepositoryProvider,
    )
        .getTransactions(
      gymId: gym.id,
    );
  },
);

final revenueBreakdownProvider =
FutureProvider<
    List<RevenueBreakdown>>(
      (ref) async {
    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    final now =
    DateTime.now();

    final startDate =
    DateTime(
      now.year,
      now.month,
      1,
    );

    final endDate =
    DateTime(
      now.year,
      now.month + 1,
      1,
    );

    return ref
        .watch(
      financeRepositoryProvider,
    )
        .getRevenueBreakdown(
      gymId: gym.id,
      startDate: startDate,
      endDate: endDate,
    );
  },
);

final revenueTrendProvider =
FutureProvider<
    List<RevenueTrend>>(
      (ref) async {
    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    final now =
    DateTime.now();

    final startDate =
    DateTime(
      now.year,
      1,
      1,
    );

    final endDate =
    DateTime(
      now.year + 1,
      1,
      1,
    );

    return ref
        .watch(
      financeRepositoryProvider,
    )
        .getRevenueTrend(
      gymId: gym.id,
      startDate: startDate,
      endDate: endDate,
    );
  },
);