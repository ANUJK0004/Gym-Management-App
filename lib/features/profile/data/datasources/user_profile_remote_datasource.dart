import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _usersCollection {
    return _firestore.collection('users');
  }

  Future<UserProfileModel?> getUserProfile(
      String uid,
      ) async {
    final document = await _usersCollection
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return UserProfileModel.fromFirestore(
      document,
    );
  }

  Future<void> createUserProfile(
      UserProfileModel profile,
      ) async {
    await _usersCollection
        .doc(profile.uid)
        .set(
      profile.toFirestore(),
    );
  }

  Future<void> updateUserProfile(
      UserProfileModel profile,
      ) async {
    await _usersCollection
        .doc(profile.uid)
        .update(
      profile.toFirestore(),
    );
  }

  Future<void> deleteUserProfile(
      String uid,
      ) async {
    await _usersCollection
        .doc(uid)
        .delete();
  }
}