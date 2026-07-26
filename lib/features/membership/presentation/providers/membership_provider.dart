import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/membership_remote_datasource.dart';
import '../../data/repositories/membership_repository_impl.dart';

import '../../domain/entities/membership.dart';
import '../../domain/repositories/membership_repository.dart';

final membershipDataSourceProvider =
Provider<MembershipRemoteDataSource>((ref) {
  return MembershipRemoteDataSource(
    FirebaseFirestore.instance,
  );
});

final membershipRepositoryProvider =
Provider<MembershipRepository>((ref) {
  return MembershipRepositoryImpl(
    ref.watch(
      membershipDataSourceProvider,
    ),
  );
});

final membershipProvider =
FutureProvider<List<Membership>>((ref) async {
  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    return [];
  }

  final repository =
  ref.watch(
    membershipRepositoryProvider,
  );

  return repository.getUserMemberships(
    authUser.id,
  );
});

final activeMembershipProvider =
Provider<Membership?>((ref) {
  final membershipsAsync =
  ref.watch(
    membershipProvider,
  );

  return membershipsAsync.when(
    data: (memberships) {
      for (final membership
      in memberships) {
        if (membership.isActive &&
            !membership.isExpired) {
          return membership;
        }
      }

      return null;
    },
    loading: () => null,
    error: (_,_) => null,
  );
});

final membershipByIdProvider =
FutureProvider.family<Membership?, String>(
      (ref, membershipId) async {
    final repository =
    ref.watch(
      membershipRepositoryProvider,
    );

    return repository.getMembership(
      membershipId,
    );
  },
);