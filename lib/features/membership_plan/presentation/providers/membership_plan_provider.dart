import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/membership_plan_remote_datasource.dart';
import '../../data/repositories/membership_plan_repository_impl.dart';
import '../../domain/entities/membership_plan.dart';
import '../../domain/repositories/membership_plan_repository.dart';

enum MembershipPlanActionResult {
  created,
  duplicate,
  updated,
  noChanges,
  activated,
  deactivated,
  deleted,
  disabledBecauseInUse,
  failed,
}

final membershipPlanFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final membershipPlanRemoteDataSourceProvider =
Provider<MembershipPlanRemoteDataSource>((ref) {
  return MembershipPlanRemoteDataSource(
    ref.watch(
      membershipPlanFirestoreProvider,
    ),
  );
});

final membershipPlanRepositoryProvider =
Provider<MembershipPlanRepository>((ref) {
  return MembershipPlanRepositoryImpl(
    ref.watch(
      membershipPlanRemoteDataSourceProvider,
    ),
  );
});

final ownerMembershipPlansProvider =
FutureProvider<List<MembershipPlan>>((ref) async {
  final gym = await ref.watch(
    ownerGymProvider.future,
  );

  if (gym == null) {
    return [];
  }

  final repository = ref.watch(
    membershipPlanRepositoryProvider,
  );

  return repository.getMembershipPlans(
    gym.id,
  );
});

final membershipPlanControllerProvider =
AsyncNotifierProvider<
    MembershipPlanController,
    void>(
  MembershipPlanController.new,
);

class MembershipPlanController
    extends AsyncNotifier<void> {
  late final MembershipPlanRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(
      membershipPlanRepositoryProvider,
    );
  }

  Future<void> _refreshPlans() async {
    ref.invalidate(
      ownerMembershipPlansProvider,
    );

    try {
      await ref.read(
        ownerMembershipPlansProvider.future,
      );
    } catch (_) {
      // The mutation itself has already succeeded.
      // A refresh failure must not turn a successful
      // create/update/delete into a failed operation.
    }
  }

  Future<void> _logActivity(
      Future<void> Function() action,
      ) async {
    try {
      await action();
    } catch (_) {
      // Activity logging must never make the actual
      // membership-plan operation fail.
    }
  }

  Future<MembershipPlanActionResult> createPlan({
    required String gymId,
    required String name,
    required double price,
    required int durationInDays,
    String? description,
  }) async {
    state = const AsyncLoading();

    try {
      final plans = await _repository.getMembershipPlans(
        gymId,
      );

      final normalizedName =
      name.trim().toLowerCase();

      final duplicate = plans.any(
            (existing) =>
        existing.name.trim().toLowerCase() ==
            normalizedName &&
            existing.price == price &&
            existing.durationInDays ==
                durationInDays,
      );

      if (duplicate) {
        state = const AsyncData(null);
        return MembershipPlanActionResult
            .duplicate;
      }

      final plan = MembershipPlan(
        id: '',
        gymId: gymId,
        name: name.trim(),
        price: price,
        durationInDays: durationInDays,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final createdPlan =
      await _repository.createMembershipPlan(
        plan,
      );

      await _refreshPlans();

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await _logActivity(
              () => ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type:
            ActivityType.membershipPlanCreated,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: createdPlan.id,
              name: createdPlan.name,
              type: 'membership_plan',
            ),
            metadata: {
              'price': createdPlan.price,
              'duration':
              createdPlan.durationInDays,
            },
          ),
        );
      }

      ref.invalidate(
        recentActivityProvider,
      );

      state = const AsyncData(null);

      return MembershipPlanActionResult
          .created;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return MembershipPlanActionResult.failed;
    }
  }

  Future<MembershipPlanActionResult> updatePlan({
    required MembershipPlan plan,
    required String gymId,
    required String name,
    required double price,
    required int durationInDays,
    String? description,
    required bool isActive,
  }) async {
    state = const AsyncLoading();

    try {
      final plans = await _repository.getMembershipPlans(
        gymId,
      );

      final normalizedName =
      name.trim().toLowerCase();

      final duplicate = plans.any(
            (existing) =>
        existing.id != plan.id &&
            existing.name.trim().toLowerCase() ==
                normalizedName &&
            existing.price == price &&
            existing.durationInDays ==
                durationInDays,
      );

      if (duplicate) {
        state = const AsyncData(null);
        return MembershipPlanActionResult
            .duplicate;
      }

      final updatedPlan = plan.copyWith(
        gymId: gymId,
        name: name.trim(),
        price: price,
        durationInDays: durationInDays,
        description: description,
        isActive: isActive,
      );

      await _repository.updateMembershipPlan(
        updatedPlan,
      );

      await _refreshPlans();

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await _logActivity(
              () => ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type:
            ActivityType.membershipPlanUpdated,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: updatedPlan.id,
              name: updatedPlan.name,
              type: 'membership_plan',
            ),
            metadata: {
              'price': updatedPlan.price,
              'duration':
              updatedPlan.durationInDays,
              'active':
              updatedPlan.isActive,
            },
          ),
        );
      }

      ref.invalidate(
        recentActivityProvider,
      );

      state = const AsyncData(null);

      return MembershipPlanActionResult
          .updated;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return MembershipPlanActionResult.failed;
    }
  }

  Future<MembershipPlanActionResult>
  togglePlanStatus({
    required MembershipPlan plan,
    required String gymId,
  }) async {
    state = const AsyncLoading();

    try {
      final updated = plan.copyWith(
        gymId: gymId,
        isActive: !plan.isActive,
      );

      await _repository.updateMembershipPlan(
        updated,
      );

      await _refreshPlans();

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await _logActivity(
              () => ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type: updated.isActive
                ? ActivityType
                .membershipPlanActivated
                : ActivityType
                .membershipPlanDeactivated,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: updated.id,
              name: updated.name,
              type: 'membership_plan',
            ),
            metadata: {
              'active':
              updated.isActive,
            },
          ),
        );
      }

      ref.invalidate(
        recentActivityProvider,
      );

      state = const AsyncData(null);

      return updated.isActive
          ? MembershipPlanActionResult
          .activated
          : MembershipPlanActionResult
          .deactivated;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return MembershipPlanActionResult.failed;
    }
  }

  Future<MembershipPlanActionResult>
  deletePlan({
    required MembershipPlan plan,
    required String gymId,
  }) async {
    state = const AsyncLoading();

    try {
      final isInUse =
      await _repository.hasMembersUsingPlan(
        gymId,
        plan.id,
      );

      if (isInUse) {
        final disabledPlan = plan.copyWith(
          gymId: gymId,
          isActive: false,
        );

        await _repository.updateMembershipPlan(
          disabledPlan,
        );

        await _refreshPlans();

        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner != null) {
          await _logActivity(
                () => ref
                .read(activityServiceProvider)
                .log(
              gymId: gymId,
              type: ActivityType
                  .membershipPlanDeactivated,
              actor: ActivityActor(
                id: owner.uid,
                name:
                owner.displayName ??
                    'Owner',
                role: 'owner',
              ),
              target: ActivityTarget(
                id: plan.id,
                name: plan.name,
                type: 'membership_plan',
              ),
              metadata: {
                'reason':
                'Plan is currently used by members.',
              },
            ),
          );
        }

        ref.invalidate(
          recentActivityProvider,
        );

        state = const AsyncData(null);

        return MembershipPlanActionResult
            .disabledBecauseInUse;
      }

      await _repository.deleteMembershipPlan(
        gymId,
        plan.id,
      );

      await _refreshPlans();

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await _logActivity(
              () => ref
              .read(activityServiceProvider)
              .log(
            gymId: gymId,
            type:
            ActivityType
                .membershipPlanDeleted,
            actor: ActivityActor(
              id: owner.uid,
              name:
              owner.displayName ??
                  'Owner',
              role: 'owner',
            ),
            target: ActivityTarget(
              id: plan.id,
              name: plan.name,
              type: 'membership_plan',
            ),
          ),
        );
      }

      ref.invalidate(
        recentActivityProvider,
      );

      state = const AsyncData(null);

      return MembershipPlanActionResult
          .deleted;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return MembershipPlanActionResult.failed;
    }
  }
}