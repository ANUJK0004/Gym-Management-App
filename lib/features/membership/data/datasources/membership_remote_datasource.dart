import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/membership_model.dart';

class MembershipRemoteDataSource {
  MembershipRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _membershipsCollection {
    return _firestore.collection(
      'memberships',
    );
  }

  Future<List<MembershipModel>>
  getUserMemberships(
      String userId,
      ) async {
    final querySnapshot =
    await _membershipsCollection
        .where(
      'userId',
      isEqualTo: userId,
    )
        .get();

    return querySnapshot.docs
        .map(
      MembershipModel.fromFirestore,
    )
        .toList();
  }

  Future<MembershipModel?> getMembership(
      String membershipId,
      ) async {
    final document =
    await _membershipsCollection
        .doc(membershipId)
        .get();

    if (!document.exists) {
      return null;
    }

    return MembershipModel.fromFirestore(
      document,
    );
  }
}





