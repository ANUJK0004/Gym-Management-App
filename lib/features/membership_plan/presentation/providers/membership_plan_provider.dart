import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/membership_plan_remote_datasource.dart';
import '../../data/repositories/membership_plan_repository_impl.dart';

import '../../domain/entities/membership_plan.dart';
import '../../domain/repositories/membership_plan_repository.dart';

import '../../../gym/presentation/providers/gym_provider.dart';

final membershipPlanFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final membershipPlanRemoteDataSourceProvider =
Provider<MembershipPlanRemoteDataSource>(
      (ref) {
    return MembershipPlanRemoteDataSource(
      ref.watch(
        membershipPlanFirestoreProvider,
      ),
    );
  },
);

final membershipPlanRepositoryProvider =
Provider<MembershipPlanRepository>(
      (ref) {
    return MembershipPlanRepositoryImpl(
      ref.watch(
        membershipPlanRemoteDataSourceProvider,
      ),
    );
  },
);

final ownerMembershipPlansProvider =
FutureProvider<List<MembershipPlan>>(
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
      membershipPlanRepositoryProvider,
    );

    return repository.getMembershipPlans(
      gym.id,
    );
  },
);

final membershipPlanControllerProvider =
AsyncNotifierProvider<
    MembershipPlanController,
    void>(
  MembershipPlanController.new,
);

class MembershipPlanController
    extends AsyncNotifier<void> {
  late final MembershipPlanRepository
  _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(
      membershipPlanRepositoryProvider,
    );
  }

  Future<void> createPlan({
    required String gymId,
    required String name,
    required double price,
    required int durationInDays,
    String? description,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final plan = MembershipPlan(
        id: '',
        gymId: gymId,
        name: name,
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

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await ref
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
        );
      }

      ref.invalidate(
        ownerMembershipPlansProvider,
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }

  Future<void> updatePlan({
    required MembershipPlan plan,
    required String name,
    required double price,
    required int durationInDays,
    String? description,
    required bool isActive,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedPlan =
      plan.copyWith(
        name: name,
        price: price,
        durationInDays:
        durationInDays,
        description: description,
        isActive: isActive,
      );

      await _repository.updateMembershipPlan(
        updatedPlan,
      );

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await ref
            .read(activityServiceProvider)
            .log(
          gymId: plan.gymId,

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
            id: plan.id,
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
        );
      }

      ref.invalidate(
        ownerMembershipPlansProvider,
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }

  Future<void> togglePlanStatus(
      MembershipPlan plan,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updated =
      plan.copyWith(
        isActive: !plan.isActive,
      );

      await _repository
          .updateMembershipPlan(
        updated,
      );

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await ref
            .read(activityServiceProvider)
            .log(
          gymId: plan.gymId,

          type: updated.isActive
              ? ActivityType.membershipPlanActivated
              : ActivityType.membershipPlanDeactivated,

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
            'active':
            updated.isActive,
          },
        );
      }

      ref.invalidate(
        ownerMembershipPlansProvider,
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }

  Future<void> deletePlan(
      MembershipPlan plan,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteMembershipPlan(
        plan.gymId,
        plan.id,
      );

      final owner =
          ref.read(firebaseAuthProvider).currentUser;

      if (owner != null) {
        await ref
            .read(activityServiceProvider)
            .log(
          gymId: plan.gymId,

          type:
          ActivityType.membershipPlanDeleted,

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
        );
      }

      ref.invalidate(
        ownerMembershipPlansProvider,
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }
}