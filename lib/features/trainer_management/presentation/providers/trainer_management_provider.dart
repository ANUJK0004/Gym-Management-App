import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/trainer_management_remote_datasource.dart';
import '../../data/repositories/trainer_management_repository_impl.dart';

import '../../domain/entities/managed_trainer.dart';
import '../../domain/repositories/trainer_management_repository.dart';

final trainerFirestoreProvider =
Provider<FirebaseFirestore>(
      (ref) {
    return FirebaseFirestore.instance;
  },
);

final trainerManagementRemoteDataSourceProvider =
Provider<
    TrainerManagementRemoteDataSource>(
      (ref) {
    return TrainerManagementRemoteDataSource(
      ref.watch(
        trainerFirestoreProvider,
      ),
    );
  },
);

final trainerManagementRepositoryProvider =
Provider<
    TrainerManagementRepository>(
      (ref) {
    return TrainerManagementRepositoryImpl(
      ref.watch(
        trainerManagementRemoteDataSourceProvider,
      ),
    );
  },
);

// ------------------------------------------------------------
// GYM TRAINERS
// ------------------------------------------------------------

final gymTrainersProvider =
FutureProvider<
    List<ManagedTrainer>>(
      (ref) async {
    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    final repository =
    ref.watch(
      trainerManagementRepositoryProvider,
    );

    return repository
        .getGymTrainers(
      gym.id,
    );
  },
);

// ------------------------------------------------------------
// SINGLE TRAINER
// ------------------------------------------------------------

final trainerDetailsProvider =
FutureProvider.family<
    ManagedTrainer?,
    String>(
      (ref, trainerUid) async {
    final repository =
    ref.watch(
      trainerManagementRepositoryProvider,
    );

    return repository.getTrainer(
      trainerUid,
    );
  },
);

// ------------------------------------------------------------
// SEARCH TRAINERS
// ------------------------------------------------------------

final trainerSearchProvider =
FutureProvider.family<
    List<ManagedTrainer>,
    String>(
      (ref, query) async {
    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null ||
        query.trim().isEmpty) {
      return [];
    }

    final repository =
    ref.watch(
      trainerManagementRepositoryProvider,
    );

    return repository.searchTrainers(
      gym.id,
      query.trim(),
    );
  },
);