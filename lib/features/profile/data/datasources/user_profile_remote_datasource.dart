import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  // ----------------------------------------------------------
  // GET PROFILE
  // ----------------------------------------------------------

  Future<UserProfileModel?> getUserProfile(String uid) async {
    final document = await _usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserProfileModel.fromFirestore(document);
  }

  // ----------------------------------------------------------
  // CREATE PROFILE
  // ----------------------------------------------------------

  Future<void> createUserProfile(UserProfileModel profile) async {
    final data = profile.toFirestore();

    data['createdAt'] = FieldValue.serverTimestamp();

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _usersCollection.doc(profile.uid).set(data);
  }

  // ----------------------------------------------------------
  // UPDATE PROFILE
  // ----------------------------------------------------------

  Future<void> updateUserProfile(UserProfileModel profile) async {
    final data = profile.toFirestore();

    // Never overwrite the original
    // creation timestamp during updates.
    data.remove('createdAt');

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _usersCollection.doc(profile.uid).set(data, SetOptions(merge: true));
  }

  // ----------------------------------------------------------
  // DELETE PROFILE
  // ----------------------------------------------------------

  Future<void> deleteUserProfile(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}
