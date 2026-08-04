import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/owner_settings_remote_datasource.dart';
import '../../data/repositories/owner_settings_repository_impl.dart';
import '../../domain/entities/owner_settings.dart';
import '../../domain/repositories/owner_settings_repository.dart';

final ownerSettingsFirestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final ownerSettingsRemoteDataSourceProvider =
Provider<OwnerSettingsRemoteDataSource>(
      (ref) {
    return OwnerSettingsRemoteDataSource(
      ref.watch(
        ownerSettingsFirestoreProvider,
      ),
    );
  },
);

final ownerSettingsRepositoryProvider =
Provider<OwnerSettingsRepository>(
      (ref) {
    return OwnerSettingsRepositoryImpl(
      ref.watch(
        ownerSettingsRemoteDataSourceProvider,
      ),
    );
  },
);

final ownerSettingsProvider =
FutureProvider<OwnerSettings?>(
      (ref) async {
    final user =
        ref.watch(
          firebaseAuthProvider,
        ).currentUser;

    if (user == null) {
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
      ownerSettingsRepositoryProvider,
    );

    return repository
        .getOwnerSettings(
      ownerId: user.uid,
      gymId: gym.id,
    );
  },
);