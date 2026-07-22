import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(
      String uid,
      );

  Future<void> createUserProfile(
      UserProfile profile,
      );

  Future<void> updateUserProfile(
      UserProfile profile,
      );

  Future<void> deleteUserProfile(
      String uid,
      );
}