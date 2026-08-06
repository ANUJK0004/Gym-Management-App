import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';

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
Provider<TrainerManagementRemoteDataSource>(
      (ref) {
    return TrainerManagementRemoteDataSource(
      ref.watch(
        trainerFirestoreProvider,
      ),
    );
  },
);

final trainerManagementRepositoryProvider =
Provider<TrainerManagementRepository>(
      (ref) {
    return TrainerManagementRepositoryImpl(
      ref.watch(
        trainerManagementRemoteDataSourceProvider,
      ),
    );
  },
);

/// ------------------------------------------------------------
/// GYM TRAINERS
/// ------------------------------------------------------------

final gymTrainersProvider =
FutureProvider<List<ManagedTrainer>>(
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

    return repository.getGymTrainers(
      gym.id,
    );
  },
);

/// ------------------------------------------------------------
/// SINGLE TRAINER
/// ------------------------------------------------------------

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

/// ------------------------------------------------------------
/// SEARCH TRAINERS
/// ------------------------------------------------------------

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

/// ------------------------------------------------------------
/// CONTROLLER
/// ------------------------------------------------------------

class TrainerManagementController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> assignTrainer({
    required ManagedTrainer trainer,
    required String gymId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        final repository = ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.assignTrainerToGym(
          trainerUid: trainer.uid,
          gymId: gymId,
        );

        final owner =
            ref.read(firebaseAuthProvider).currentUser;

        if (owner != null) {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type: ActivityType.trainerAssigned,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: trainer.uid,
              name:
              trainer.displayName ??
                  trainer.email,
              type: 'trainer',
            ),
          );
        }

        ref.invalidate(
          gymTrainersProvider,
        );

        ref.invalidate(
          trainerDetailsProvider(
            trainer.uid,
          ),
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }

  Future<void> updateTrainer(
      ManagedTrainer trainer,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        final repository = ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.updateTrainer(
          trainer,
        );

        final owner =
            ref.read(firebaseAuthProvider).currentUser;

        if (owner != null &&
            trainer.gymId != null) {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: trainer.gymId!,
            type:
            ActivityType.profileUpdated,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: trainer.uid,
              name:
              trainer.displayName ??
                  trainer.email,
              type: 'trainer',
            ),
          );
        }

        ref.invalidate(
          gymTrainersProvider,
        );

        ref.invalidate(
          trainerDetailsProvider(
            trainer.uid,
          ),
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }

  Future<void> removeTrainer({
    required ManagedTrainer trainer,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        final repository = ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.removeTrainerFromGym(
          trainer.uid,
        );

        final owner =
            ref.read(firebaseAuthProvider).currentUser;

        if (owner != null &&
            trainer.gymId != null) {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: trainer.gymId!,
            type:
            ActivityType.trainerRemoved,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: trainer.uid,
              name:
              trainer.displayName ??
                  trainer.email,
              type: 'trainer',
            ),
          );
        }

        ref.invalidate(
          gymTrainersProvider,
        );

        ref.invalidate(
          trainerDetailsProvider(
            trainer.uid,
          ),
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }
}

final trainerManagementControllerProvider =
AsyncNotifierProvider<
    TrainerManagementController,
    void>(
  TrainerManagementController.new,
);