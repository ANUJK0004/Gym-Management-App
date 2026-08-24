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

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs
          .map(
        MembershipModel.fromFirestore,
      )
          .toList();
    }

    // Fallback: Check user's assigned gym & plan
    final active = await getActiveMembership(userId);
    if (active != null) {
      return [active];
    }

    return [];
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

  Future<MembershipModel?> getActiveMembership(
      String userId,
      ) async {
    try {
      final querySnapshot =
      await _membershipsCollection
          .where(
        'userId',
        isEqualTo: userId,
      )
          .where(
        'status',
        isEqualTo: 'Active',
      )
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final membership =
        MembershipModel.fromFirestore(
          querySnapshot.docs.first,
        );

        if (!membership.isExpired) {
          return membership;
        }
      }
    } catch (_) {}

    // Fallback: Resolve active membership from user profile and gym data
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data() ?? {};
      final gymId = userData['gymId'] as String?;
      final membershipStatus = userData['membershipStatus'] as String?;
      final membershipPlanId = userData['membershipPlanId'] as String?;

      if (gymId != null &&
          gymId.isNotEmpty &&
          (membershipStatus == 'active' ||
              membershipStatus == 'Active' ||
              membershipPlanId != null)) {
        final gymDoc = await _firestore.collection('gyms').doc(gymId).get();
        final gymName = gymDoc.data()?['name'] as String? ?? 'Your Gym';

        String planName = 'Standard Membership';
        double? price;
        int durationMonths = 1;

        if (membershipPlanId != null && membershipPlanId.isNotEmpty) {
          final planDoc = await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('membershipPlans')
              .doc(membershipPlanId)
              .get();

          if (planDoc.exists) {
            final planData = planDoc.data() ?? {};
            planName = planData['name'] as String? ?? planName;
            price = (planData['price'] as num?)?.toDouble();
            durationMonths = (planData['durationMonths'] as num?)?.toInt() ?? 1;
          }
        }

        final rawJoined = userData['joinedAt'];
        DateTime startDate = DateTime.now();
        if (rawJoined is Timestamp) {
          startDate = rawJoined.toDate();
        }

        final expiryDate = startDate.add(Duration(days: durationMonths * 30));

        return MembershipModel(
          id: 'user_active_$userId',
          userId: userId,
          gymId: gymId,
          gymName: gymName,
          status: 'Active',
          membershipType: planName,
          startDate: startDate,
          expiryDate: expiryDate,
          price: price,
          paymentStatus: 'Paid',
          autoRenew: false,
        );
      }
    } catch (_) {}

    return null;
  }
}