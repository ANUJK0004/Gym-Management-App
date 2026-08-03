import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

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

class MemberManagementController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> assignMember({
    required String uid,
    required String gymId,
  }) async {
    state =
    const AsyncLoading();

    state =
    await AsyncValue.guard(
          () async {
        final repository =
        ref.read(
          memberManagementRepositoryProvider,
        );

        await repository
            .assignMemberToGym(
          uid: uid,
          gymId: gymId,
        );

        ref.invalidate(
          gymMembersProvider,
        );

        ref.invalidate(
          memberDetailsProvider(
            uid,
          ),
        );
      },
    );
  }

  Future<void> removeMember({
    required String uid,
  }) async {
    state =
    const AsyncLoading();

    state =
    await AsyncValue.guard(
          () async {
        final repository =
        ref.read(
          memberManagementRepositoryProvider,
        );

        await repository
            .removeMemberFromGym(
          uid,
        );

        ref.invalidate(
          gymMembersProvider,
        );

        ref.invalidate(
          memberDetailsProvider(
            uid,
          ),
        );
      },
    );
  }
}

final memberManagementControllerProvider =
AsyncNotifierProvider<
    MemberManagementController,
    void>(
  MemberManagementController.new,
);