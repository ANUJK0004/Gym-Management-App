import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/owner_dashboard_remote_datasource.dart';
import '../../data/repositories/owner_dashboard_repository_impl.dart';

import '../../domain/entities/owner_dashboard_data.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';

final ownerDashboardRemoteDatasourceProvider =
Provider(
      (ref) => OwnerDashboardRemoteDataSource(
    FirebaseFirestore.instance,
  ),
);

final ownerDashboardRepositoryProvider =
Provider<OwnerDashboardRepository>(
      (ref) {
    return OwnerDashboardRepositoryImpl(
      ref.watch(
        ownerDashboardRemoteDatasourceProvider,
      ),
    );
  },
);

final ownerDashboardProvider =
FutureProvider<OwnerDashboardData>(
      (ref) async {
    final user = ref
        .watch(firebaseAuthProvider)
        .currentUser;

    if (user == null) {
      throw Exception(
        'Owner not authenticated.',
      );
    }

    final repository = ref.watch(
      ownerDashboardRepositoryProvider,
    );

    return repository.getDashboard(
      ownerId: user.uid,
    );
  },
);