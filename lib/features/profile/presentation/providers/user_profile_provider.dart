import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';

final firestoreProvider =
Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userProfileDataSourceProvider =
Provider<UserProfileRemoteDataSource>((ref) {
  return UserProfileRemoteDataSource(
    ref.watch(firestoreProvider),
  );
});

final userProfileRepositoryProvider =
Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    ref.watch(userProfileDataSourceProvider),
  );
});