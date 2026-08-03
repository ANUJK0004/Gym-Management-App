import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_management_model.dart';

class MemberManagementRemoteDataSource {
  MemberManagementRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _usersCollection {
    return _firestore.collection('users');
  }

  Future<List<MemberManagementModel>>
  getMembersByGymId(
      String gymId,
      ) async {
    final querySnapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'member',
    )
        .get();

    return querySnapshot.docs
        .map(
      MemberManagementModel.fromFirestore,
    )
        .toList();
  }

  Future<MemberManagementModel?>
  getMemberById(
      String uid,
      ) async {
    final document =
    await _usersCollection
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null ||
        data['role'] != 'member') {
      return null;
    }

    return MemberManagementModel
        .fromFirestore(
      document,
    );
  }

  Future<List<MemberManagementModel>>
  searchMembers(
      String query,
      ) async {
    final normalizedQuery =
    query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final querySnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'member',
    )
        .get();

    final members = querySnapshot.docs
        .map(
      MemberManagementModel
          .fromFirestore,
    )
        .where(
          (member) {
        final name =
            member.displayName
                ?.toLowerCase() ??
                '';

        final email =
        member.email
            .toLowerCase();

        return name.contains(
          normalizedQuery,
        ) ||
            email.contains(
              normalizedQuery,
            );
      },
    )
        .toList();

    return members;
  }

  Future<void> assignMemberToGym({
    required String uid,
    required String gymId,
  }) async {
    await _usersCollection
        .doc(uid)
        .update({
      'gymId': gymId,
      'joinedAt':
      FieldValue.serverTimestamp(),
      'membershipStatus':
      'pending',
    });
  }

  Future<void> removeMemberFromGym(
      String uid,
      ) async {
    await _usersCollection
        .doc(uid)
        .update({
      'gymId':
      FieldValue.delete(),
      'joinedAt':
      FieldValue.delete(),
      'membershipPlanId':
      FieldValue.delete(),
      'membershipStatus':
      FieldValue.delete(),
    });
  }
}