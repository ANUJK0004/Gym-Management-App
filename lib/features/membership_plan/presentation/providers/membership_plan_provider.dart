import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final gymAsync =
    ref.watch(ownerGymProvider);

    final gym = gymAsync.value;

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

    state = await AsyncValue.guard(
          () async {
        final plan =
        MembershipPlan(
          id: '',
          gymId: gymId,
          name: name,
          price: price,
          durationInDays:
          durationInDays,
          description:
          description,
          isActive: true,
          createdAt:
          DateTime.now(),
        );

        await _repository
            .createMembershipPlan(
          plan,
        );

        ref.invalidate(
          ownerMembershipPlansProvider,
        );
      },
    );
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

    state = await AsyncValue.guard(
          () async {
        final updatedPlan =
        plan.copyWith(
          name: name,
          price: price,
          durationInDays:
          durationInDays,
          description:
          description,
          isActive:
          isActive,
        );

        await _repository
            .updateMembershipPlan(
          updatedPlan,
        );

        ref.invalidate(
          ownerMembershipPlansProvider,
        );
      },
    );
  }

  Future<void> togglePlanStatus(
      MembershipPlan plan,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        await _repository
            .updateMembershipPlan(
          plan.copyWith(
            isActive:
            !plan.isActive,
          ),
        );

        ref.invalidate(
          ownerMembershipPlansProvider,
        );
      },
    );
  }

  Future<void> deletePlan(
      MembershipPlan plan,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        await _repository
            .deleteMembershipPlan(
          plan.gymId,
          plan.id,
        );

        ref.invalidate(
          ownerMembershipPlansProvider,
        );
      },
    );
  }
}