import 'package:sweatsync/features/profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:sweatsync/features/profile/data/models/user_profile_model.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl
    implements UserProfileRepository {
  UserProfileRepositoryImpl(
      this._dataSource,
      );

  final UserProfileRemoteDataSource _dataSource;

  @override
  Future<UserProfile?> getUserProfile(
      String uid,
      ) {
    return _dataSource.getUserProfile(uid);
  }

  @override
  Future<void> createUserProfile(
      UserProfile profile,
      ) {
    final model = UserProfileModel(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      height: profile.height,
      weight: profile.weight,
      fitnessGoal: profile.fitnessGoal,
      activityLevel: profile.activityLevel,
      profileCompleted: profile.profileCompleted,
    );

    return _dataSource.createUserProfile(model);
  }

  @override
  Future<void> updateUserProfile(
      UserProfile profile,
      ) {
    final model = UserProfileModel(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      height: profile.height,
      weight: profile.weight,
      fitnessGoal: profile.fitnessGoal,
      activityLevel: profile.activityLevel,
      profileCompleted: profile.profileCompleted,
    );

    return _dataSource.updateUserProfile(model);
  }

  @override
  Future<void> deleteUserProfile(
      String uid,
      ) {
    return _dataSource.deleteUserProfile(uid);
  }
}