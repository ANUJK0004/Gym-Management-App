import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/gym_remote_datasource.dart';
import '../../data/repositories/gym_repository_impl.dart';
import '../../domain/entities/gym.dart';
import '../../domain/repositories/gym_repository.dart';

final firestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final gymRemoteDataSourceProvider =
Provider<GymRemoteDataSource>((ref) {
  return GymRemoteDataSource(
    ref.watch(firestoreProvider),
  );
});

final gymRepositoryProvider =
Provider<GymRepository>((ref) {
  return GymRepositoryImpl(
    ref.watch(
      gymRemoteDataSourceProvider,
    ),
  );
});

final ownerGymProvider =
FutureProvider<Gym?>((ref) async {
  final user = ref.watch(
    firebaseAuthProvider,
  ).currentUser;

  if (user == null) {
    return null;
  }

  final repository = ref.watch(
    gymRepositoryProvider,
  );

  return repository.getGymByOwnerId(
    user.uid,
  );
});