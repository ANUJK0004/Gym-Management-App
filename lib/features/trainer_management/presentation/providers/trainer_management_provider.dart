import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';

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

// ------------------------------------------------------------
// GYM TRAINERS
// ------------------------------------------------------------

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

    return ref
        .read(
      trainerManagementRepositoryProvider,
    )
        .getGymTrainers(gym.id);
  },
);

// ------------------------------------------------------------
// SINGLE TRAINER
// ------------------------------------------------------------

final trainerDetailsProvider =
FutureProvider.family<
    ManagedTrainer?,
    String>(
      (ref, trainerUid) {
    return ref
        .read(
      trainerManagementRepositoryProvider,
    )
        .getTrainer(trainerUid);
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
    final normalizedQuery =
    query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    return ref
        .read(
      trainerManagementRepositoryProvider,
    )
        .searchTrainers(
      gymId: gym.id,
      query: normalizedQuery,
    );
  },
);

// ------------------------------------------------------------
// EXACT EMAIL LOOKUP
// ------------------------------------------------------------

final trainerEmailLookupProvider =
FutureProvider.family<
    ManagedTrainer?,
    String>(
      (ref, email) async {
    final normalizedEmail =
    email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return null;
    }

    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return null;
    }

    return ref
        .read(
      trainerManagementRepositoryProvider,
    )
        .findEligibleTrainerByEmail(
      email: normalizedEmail,
      gymId: gym.id,
    );
  },
);

// ------------------------------------------------------------
// CONTROLLER
// ------------------------------------------------------------

final trainerManagementControllerProvider =
AsyncNotifierProvider<
    TrainerManagementController,
    void>(
  TrainerManagementController.new,
);

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
        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner == null) {
          throw Exception(
            'No authenticated owner found.',
          );
        }

        final ownerGym =
        await ref.watch(
          ownerGymProvider.future,
        );

        if (ownerGym == null ||
            ownerGym.id != gymId) {
          throw Exception(
            'You are not authorized to manage this gym.',
          );
        }

        if (trainer.gymId != null &&
            trainer.gymId!.isNotEmpty) {
          if (trainer.gymId == gymId) {
            throw Exception(
              'This trainer is already assigned to your gym.',
            );
          }

          throw Exception(
            'This trainer belongs to another gym.',
          );
        }

        final repository =
        ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.assignTrainerToGym(
          trainerUid: trainer.uid,
          gymId: gymId,
        );

        try {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type: ActivityType.trainerAssigned,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ?? 'Owner',
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
        } catch (_) {}

        ref.invalidate(
          gymTrainersProvider,
        );

        ref.invalidate(
          trainerDetailsProvider(
            trainer.uid,
          ),
        );

        ref.invalidate(
          trainerSearchProvider,
        );

        ref.invalidate(
          trainerEmailLookupProvider(
            trainer.email,
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
        if (!trainer.isAssignedToGym) {
          throw Exception(
            'Trainer is not assigned to a gym.',
          );
        }

        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner == null) {
          throw Exception(
            'No authenticated owner found.',
          );
        }

        final ownerGym =
        await ref.watch(
          ownerGymProvider.future,
        );

        if (ownerGym == null ||
            trainer.gymId != ownerGym.id) {
          throw Exception(
            'This trainer does not belong to your gym.',
          );
        }

        final repository =
        ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.updateTrainer(
          trainer,
        );

        try {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: ownerGym.id,
            type: ActivityType.profileUpdated,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ?? 'Owner',
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
        } catch (_) {}

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
        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner == null) {
          throw Exception(
            'No authenticated owner found.',
          );
        }

        final ownerGym =
        await ref.watch(
          ownerGymProvider.future,
        );

        if (ownerGym == null ||
            trainer.gymId != ownerGym.id) {
          throw Exception(
            'This trainer does not belong to your gym.',
          );
        }

        final repository =
        ref.read(
          trainerManagementRepositoryProvider,
        );

        await repository.removeTrainerFromGym(
          trainer.uid,
        );

        try {
          await ref
              .read(activityServiceProvider)
              .log(
            gymId: ownerGym.id,
            type:
            ActivityType.trainerRemoved,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ?? 'Owner',
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
        } catch (_) {}

        ref.invalidate(
          gymTrainersProvider,
        );

        ref.invalidate(
          trainerDetailsProvider(
            trainer.uid,
          ),
        );

        ref.invalidate(
          trainerSearchProvider,
        );

        ref.invalidate(
          trainerEmailLookupProvider(
            trainer.email,
          ),
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }
}