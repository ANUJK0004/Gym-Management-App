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

// ------------------------------------------------------------
// FIRESTORE
// ------------------------------------------------------------

final memberManagementFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ------------------------------------------------------------
// REMOTE DATA SOURCE
// ------------------------------------------------------------

final memberManagementRemoteDataSourceProvider =
Provider<MemberManagementRemoteDataSource>(
      (ref) {
    return MemberManagementRemoteDataSource(
      ref.watch(
        memberManagementFirestoreProvider,
      ),
    );
  },
);

// ------------------------------------------------------------
// REPOSITORY
// ------------------------------------------------------------

final memberManagementRepositoryProvider =
Provider<MemberManagementRepository>(
      (ref) {
    return MemberManagementRepositoryImpl(
      ref.watch(
        memberManagementRemoteDataSourceProvider,
      ),
    );
  },
);

// ------------------------------------------------------------
// GYM MEMBERS
// ------------------------------------------------------------

final gymMembersProvider =
FutureProvider<List<ManagedMember>>(
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
      memberManagementRepositoryProvider,
    );

    return repository.getMembersByGymId(
      gym.id,
    );
  },
);

// ------------------------------------------------------------
// SINGLE MEMBER
// ------------------------------------------------------------

final memberDetailsProvider =
FutureProvider.family<
    ManagedMember?,
    String>(
      (
      ref,
      uid,
      ) async {
    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository.getMemberById(
      uid,
    );
  },
);

// ------------------------------------------------------------
// SEARCH MEMBERS
// ------------------------------------------------------------

final memberSearchProvider =
FutureProvider.family<
    List<ManagedMember>,
    String>(
      (ref, query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final gym =
    await ref.watch(
      ownerGymProvider.future,
    );

    if (gym == null) {
      return [];
    }

    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository.searchMembers(
      query: query.trim(),
      gymId: gym.id,
    );
  },
);

// ------------------------------------------------------------
// EXACT EMAIL LOOKUP
// ------------------------------------------------------------

final memberEmailLookupProvider =
FutureProvider.family<
    ManagedMember?,
    String>(
      (
      ref,
      email,
      ) async {
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

    final repository =
    ref.watch(
      memberManagementRepositoryProvider,
    );

    return repository
        .findEligibleMemberByEmail(
      email: normalizedEmail,
      gymId: gym.id,
    );
  },
);

// ------------------------------------------------------------
// CONTROLLER
// ------------------------------------------------------------

final memberManagementControllerProvider =
AsyncNotifierProvider<
    MemberManagementController,
    void>(
  MemberManagementController.new,
);

class MemberManagementController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // ----------------------------------------------------------
  // ASSIGN MEMBER
  // ----------------------------------------------------------

  Future<void> assignMember({
    required String uid,
    required String gymId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        // ----------------------------------------------------
        // 1. Get authenticated owner
        // ----------------------------------------------------

        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner == null) {
          throw Exception(
            'No authenticated owner found.',
          );
        }

        // ----------------------------------------------------
        // 2. Verify owner's gym
        // ----------------------------------------------------

        final ownerGym =
        await ref.watch(
          ownerGymProvider.future,
        );

        if (ownerGym == null) {
          throw Exception(
            'Owner gym not found.',
          );
        }

        if (ownerGym.id != gymId) {
          throw Exception(
            'You are not authorized to '
                'manage this gym.',
          );
        }

        // ----------------------------------------------------
        // 3. Get member
        // ----------------------------------------------------

        final repository =
        ref.read(
          memberManagementRepositoryProvider,
        );

        final member =
        await repository.getMemberById(
          uid,
        );

        if (member == null) {
          throw Exception(
            'Member account not found.',
          );
        }

        // ----------------------------------------------------
        // 4. Extra protection:
        //
        // Do not allow assignment of a member already
        // belonging to another gym.
        // ----------------------------------------------------

        if (member.gymId != null &&
            member.gymId!.isNotEmpty) {
          if (member.gymId == gymId) {
            throw Exception(
              'This member is already assigned '
                  'to your gym.',
            );
          }

          throw Exception(
            'This member is already assigned '
                'to another gym.',
          );
        }

        // ----------------------------------------------------
        // 5. Assign
        // ----------------------------------------------------

        await repository.assignMemberToGym(
          uid: uid,
          gymId: gymId,
        );

        // ----------------------------------------------------
        // 6. Activity
        // ----------------------------------------------------

        try {
          await ref
              .read(
            activityServiceProvider,
          )
              .log(
            gymId: gymId,

            type:
            ActivityType.memberAssigned,

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
              'memberEmail':
              member.email,
            },
          );
        } catch (_) {
          // Activity failure must not
          // undo successful assignment.
        }

        // ----------------------------------------------------
        // 7. Refresh
        // ----------------------------------------------------

        ref.invalidate(
          gymMembersProvider,
        );

        ref.invalidate(
          memberDetailsProvider(uid),
        );

        ref.invalidate(
          memberSearchProvider,
        );

        ref.invalidate(
          memberEmailLookupProvider(
            member.email,
          ),
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }

  // ----------------------------------------------------------
  // REMOVE MEMBER
  // ----------------------------------------------------------

  Future<void> removeMember({
    required String uid,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        // ----------------------------------------------------
        // 1. Authenticated owner
        // ----------------------------------------------------

        final owner =
            ref
                .read(firebaseAuthProvider)
                .currentUser;

        if (owner == null) {
          throw Exception(
            'No authenticated owner found.',
          );
        }

        // ----------------------------------------------------
        // 2. Owner gym
        // ----------------------------------------------------

        final ownerGym =
        await ref.watch(
          ownerGymProvider.future,
        );

        if (ownerGym == null) {
          throw Exception(
            'Owner gym not found.',
          );
        }

        // ----------------------------------------------------
        // 3. Member
        // ----------------------------------------------------

        final repository =
        ref.read(
          memberManagementRepositoryProvider,
        );

        final member =
        await repository.getMemberById(
          uid,
        );

        if (member == null) {
          throw Exception(
            'Member account not found.',
          );
        }

        // ----------------------------------------------------
        // 4. Verify ownership
        // ----------------------------------------------------

        if (member.gymId !=
            ownerGym.id) {
          throw Exception(
            'This member does not belong '
                'to your gym.',
          );
        }

        // ----------------------------------------------------
        // 5. Remove
        // ----------------------------------------------------

        await repository
            .removeMemberFromGym(uid);

        // ----------------------------------------------------
        // 6. Activity
        // ----------------------------------------------------

        try {
          await ref
              .read(
            activityServiceProvider,
          )
              .log(
            gymId: ownerGym.id,

            type:
            ActivityType.memberRemoved,

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
        } catch (_) {
          // Activity failure must not
          // make removal fail.
        }

        // ----------------------------------------------------
        // 7. Refresh
        // ----------------------------------------------------

        ref.invalidate(
          gymMembersProvider,
        );

        ref.invalidate(
          memberDetailsProvider(uid),
        );

        ref.invalidate(
          memberSearchProvider,
        );

        ref.invalidate(
          recentActivityProvider,
        );
      },
    );
  }
}