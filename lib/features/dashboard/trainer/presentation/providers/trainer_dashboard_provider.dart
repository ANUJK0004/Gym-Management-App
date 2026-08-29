import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/trainer_dashboard_remote_datasource.dart';
import '../../data/repositories/trainer_dashboard_repository_impl.dart';
import '../../domain/entities/trainer_dashboard_data.dart';
import '../../domain/repositories/trainer_dashboard_repository.dart';

final trainerDashboardRemoteDataSourceProvider =
    Provider<TrainerDashboardRemoteDataSource>((ref) {
  return TrainerDashboardRemoteDataSource(FirebaseFirestore.instance);
});

final trainerDashboardRepositoryProvider =
    Provider<TrainerDashboardRepository>((ref) {
  return TrainerDashboardRepositoryImpl(
    ref.watch(trainerDashboardRemoteDataSourceProvider),
  );
});

final trainerDashboardProvider =
    FutureProvider<TrainerDashboardData>((ref) async {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  final trainerId = user?.uid ?? 'trainer_001';

  final repository = ref.watch(trainerDashboardRepositoryProvider);
  return repository.getDashboard(trainerId: trainerId);
});

class TrainerDashboardController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> startSession(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final trainerId = user?.uid ?? 'trainer_001';
      final repo = ref.read(trainerDashboardRepositoryProvider);

      await repo.startSession(trainerId: trainerId, sessionId: sessionId);
      ref.invalidate(trainerDashboardProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeSession(String sessionId, {String? clientId}) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final trainerId = user?.uid ?? 'trainer_001';
      final repo = ref.read(trainerDashboardRepositoryProvider);

      await repo.completeSession(
        trainerId: trainerId,
        sessionId: sessionId,
        clientId: clientId,
      );
      ref.invalidate(trainerDashboardProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addClient(TrainerClientProgress client) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final trainerId = user?.uid ?? 'trainer_001';
      final repo = ref.read(trainerDashboardRepositoryProvider);

      await repo.addClient(trainerId: trainerId, client: client);
      ref.invalidate(trainerDashboardProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateClientProgress({
    required String clientId,
    required int progressPercentage,
    int? sessionsCount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final trainerId = user?.uid ?? 'trainer_001';
      final repo = ref.read(trainerDashboardRepositoryProvider);

      await repo.updateClientProgress(
        trainerId: trainerId,
        clientId: clientId,
        progressPercentage: progressPercentage,
        sessionsCount: sessionsCount,
      );
      ref.invalidate(trainerDashboardProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final trainerDashboardControllerProvider =
    NotifierProvider<TrainerDashboardController, AsyncValue<void>>(
  TrainerDashboardController.new,
);
