import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/owner_dashboard_remote_datasource.dart';
import '../../data/repositories/owner_dashboard_repository_impl.dart';

import '../../domain/entities/owner_dashboard_stats.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';

final ownerDashboardRemoteDataSourceProvider =
Provider<OwnerDashboardRemoteDataSource>((ref) {
  return OwnerDashboardRemoteDataSource(
    FirebaseFirestore.instance,
  );
});

final ownerDashboardRepositoryProvider =
Provider<OwnerDashboardRepository>((ref) {
  return OwnerDashboardRepositoryImpl(
    ref.watch(
      ownerDashboardRemoteDataSourceProvider,
    ),
  );
});

final ownerDashboardStatsProvider =
FutureProvider<OwnerDashboardStats>((ref) async {
  final user =
      ref.watch(
        firebaseAuthProvider,
      ).currentUser;

  if (user == null) {
    throw Exception(
      'No authenticated owner found.',
    );
  }

  final gym =
  await ref.watch(
    ownerGymProvider.future,
  );

  if (gym == null) {
    throw Exception(
      'No gym is assigned to this owner.',
    );
  }

  final repository =
  ref.watch(
    ownerDashboardRepositoryProvider,
  );

  return repository.getDashboardStats(
    gymId: gym.id,
  );
});