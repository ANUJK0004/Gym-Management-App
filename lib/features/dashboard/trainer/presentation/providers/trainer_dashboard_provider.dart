import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/trainer_dashboard_remote_datasource.dart';
import '../../data/repositories/trainer_dashboard_repository_impl.dart';
import '../../domain/entities/trainer_dashboard_data.dart';
import '../../domain/repositories/trainer_dashboard_repository.dart';

final trainerDashboardRemoteDataSourceProvider =
    Provider<TrainerDashboardRemoteDataSource>((ref) {
  return const TrainerDashboardRemoteDataSource();
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
