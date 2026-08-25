import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/dashboard/member/presentation/providers/member_dashboard_provider.dart';

import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';

import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';

final progressDataSourceProvider =
Provider<ProgressRemoteDataSource>((ref) {
  return ProgressRemoteDataSource(
    FirebaseFirestore.instance,
  );
});

final progressRepositoryProvider =
Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    ref.watch(
      progressDataSourceProvider,
    ),
  );
});

final progressProvider =
FutureProvider<Progress>((ref) async {
  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    throw Exception(
      'User is not authenticated.',
    );
  }

  final repository =
  ref.watch(
    progressRepositoryProvider,
  );

  return repository.getProgress(
    authUser.id,
  );
});

final updateBodyMetricsProvider =
Provider<
    Future<void> Function({
    double? weight,
    double? bodyFat,
    double? muscleMass,
    })>((ref) {
  return ({
    double? weight,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final authState =
    ref.read(authStateProvider);

    final authUser =
        authState.value;

    if (authUser == null) {
      throw Exception(
        'User is not authenticated.',
      );
    }

    final repository =
    ref.read(
      progressRepositoryProvider,
    );

    await repository
        .updateBodyMetrics(
      userId: authUser.id,
      weight: weight,
      bodyFat: bodyFat,
      muscleMass: muscleMass,
    );

    ref.invalidate(
      progressProvider,
    );

    ref.invalidate(
      memberDashboardProvider,
    );
  };
});

class UpdateBodyMetricsParams {
  const UpdateBodyMetricsParams({
    required this.currentWeight,
    required this.bodyFat,
    required this.muscleMass,
  });

  final double currentWeight;
  final double bodyFat;
  final double muscleMass;
}