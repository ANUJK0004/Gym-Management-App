import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';


import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../../data/datasources/member_management_remote_datasource.dart';
import '../../data/repositories/member_management_repository_impl.dart';
import '../../domain/entities/managed_member.dart';
import '../../domain/repositories/member_management_repository.dart';

final memberManagementFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final memberManagementRemoteDataSourceProvider =
Provider<MemberManagementRemoteDataSource>((ref) {
  return MemberManagementRemoteDataSource(
    ref.watch(
      memberManagementFirestoreProvider,
    ),
  );
});

final memberManagementRepositoryProvider =
Provider<MemberManagementRepository>((ref) {
  return MemberManagementRepositoryImpl(
    ref.watch(
      memberManagementRemoteDataSourceProvider,
    ),
  );
});

final gymMembersProvider =
FutureProvider<List<ManagedMember>>(
      (ref) async {
    final user =
        ref.watch(
          firebaseAuthProvider,
        ).currentUser;

    if (user == null) {
      return [];
    }

    final gymRepository =
    ref.watch(
      gymRepositoryProvider,
    );

    final gym =
    await gymRepository
        .getGymByOwnerId(
      user.uid,
    );

    if (gym == null) {
      return [];
    }

    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository
        .getMembersByGymId(
      gym.id,
    );
  },
);

final memberDetailsProvider =
FutureProvider.family<
    ManagedMember?,
    String>(
      (ref, uid) async {
    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository
        .getMemberById(uid);
  },
);

final memberSearchProvider =
FutureProvider.family<
    List<ManagedMember>,
    String>(
      (ref, query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository.searchMembers(
      query,
    );
  },
);

class MemberManagementController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> assignMember({
    required String uid,
    required String gymId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(
        memberManagementRepositoryProvider,
      );

      final member =
      await repository.getMemberById(uid);

      await repository.assignMemberToGym(
        uid: uid,
        gymId: gymId,
      );

      final owner = ref
          .read(firebaseAuthProvider)
          .currentUser;

      if (member != null && owner != null) {
        await ref.read(activityServiceProvider).log(
          gymId: gymId,

          type: ActivityType.memberAssigned,

          actor: ActivityActor(
            id: owner.uid,
            name:
            owner.displayName ??
                'Owner',
            role: 'owner',
          ),

          target: ActivityTarget(
            id: member.uid,
            name:
            member.displayName ??
                member.email,
            type: 'member',
          ),

          metadata: {
            'memberEmail': member.email,
          },
        );
      }

      ref.invalidate(gymMembersProvider);

      ref.invalidate(
        memberDetailsProvider(uid),
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }

  Future<void> removeMember({
    required String uid,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(
        memberManagementRepositoryProvider,
      );

      final member =
      await repository.getMemberById(uid);

      await repository.removeMemberFromGym(
        uid,
      );

      final owner = ref
          .read(firebaseAuthProvider)
          .currentUser;

      if (member != null &&
          owner != null &&
          member.gymId != null) {
        await ref.read(activityServiceProvider).log(
          gymId: member.gymId!,

          type: ActivityType.memberRemoved,

          actor: ActivityActor(
            id: owner.uid,
            name:
            owner.displayName ??
                'Owner',
            role: 'owner',
          ),

          target: ActivityTarget(
            id: member.uid,
            name:
            member.displayName ??
                member.email,
            type: 'member',
          ),
        );
      }

      ref.invalidate(gymMembersProvider);

      ref.invalidate(
        memberDetailsProvider(uid),
      );

      ref.invalidate(
        recentActivityProvider,
      );
    });
  }
}

final memberManagementControllerProvider =
AsyncNotifierProvider<
    MemberManagementController,
    void>(
  MemberManagementController.new,
);