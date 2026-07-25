import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/member_dashboard_remote_datasource.dart';
import '../../data/repositories/member_dashboard_repository_impl.dart';

import '../../domain/entities/member_dashboard.dart';
import '../../domain/repositories/member_dashboard_repository.dart';

final firebaseFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final memberDashboardDataSourceProvider =
Provider<MemberDashboardRemoteDataSource>((ref) {
  return MemberDashboardRemoteDataSource(
    ref.watch(
      firebaseFirestoreProvider,
    ),
  );
});

final memberDashboardRepositoryProvider =
Provider<MemberDashboardRepository>((ref) {
  return MemberDashboardRepositoryImpl(
    ref.watch(
      memberDashboardDataSourceProvider,
    ),
  );
});

final memberDashboardProvider =
FutureProvider<MemberDashboard>((ref) async {

  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    throw Exception(
      'User is not authenticated.',
    );
  }

  final repository =
  ref.watch(
    memberDashboardRepositoryProvider,
  );

  return repository.getMemberDashboard(
    authUser.id,
  );
});