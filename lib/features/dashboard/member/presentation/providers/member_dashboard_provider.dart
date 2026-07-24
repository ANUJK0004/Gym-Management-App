import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/member_dashboard_remote_datasource.dart';
import '../../data/repositories/member_dashboard_repository_impl.dart';
import '../../domain/entities/member_dashboard.dart';
import '../../domain/repositories/member_dashboard_repository.dart';

final memberDashboardDataSourceProvider =
Provider<MemberDashboardRemoteDataSource>((ref) {
  return MemberDashboardRemoteDataSource();
});

final memberDashboardRepositoryProvider =
Provider<MemberDashboardRepository>((ref) {
  return MemberDashboardRepositoryImpl(
    ref.watch(memberDashboardDataSourceProvider),
  );
});

final memberDashboardProvider =
FutureProvider<MemberDashboard>((ref) async {
  final repository =
  ref.watch(memberDashboardRepositoryProvider);

  // Temporary UID.
  // Later this will come from FirebaseAuth.
  const uid = 'temporary-user';

  return repository.getMemberDashboard(uid);
});