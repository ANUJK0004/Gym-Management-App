import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/membership_plan_model.dart';

class MembershipPlanRemoteDataSource {
  MembershipPlanRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _plansCollection(
      String gymId,
      ) {
    final id = gymId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'Gym ID cannot be empty.',
      );
    }

    return _firestore
        .collection('gyms')
        .doc(id)
        .collection('membershipPlans');
  }

  Future<MembershipPlanModel> createMembershipPlan(
      MembershipPlanModel plan,
      ) async {
    if (plan.gymId.trim().isEmpty) {
      throw ArgumentError(
        'Gym ID cannot be empty.',
      );
    }

    final documentReference =
    _plansCollection(plan.gymId).doc();

    await documentReference.set(
      plan.toFirestore(),
    );

    return MembershipPlanModel(
      id: documentReference.id,
      gymId: plan.gymId,
      name: plan.name,
      price: plan.price,
      durationInDays: plan.durationInDays,
      description: plan.description,
      isActive: plan.isActive,
      createdAt: plan.createdAt,
    );
  }

  Future<List<MembershipPlanModel>> getMembershipPlans(
      String gymId,
      ) async {
    final querySnapshot = await _plansCollection(gymId)
        .orderBy(
      'createdAt',
      descending: true,
    )
        .get();

    return querySnapshot.docs
        .map(
      MembershipPlanModel.fromFirestore,
    )
        .toList();
  }

  Future<MembershipPlanModel?> getMembershipPlan(
      String gymId,
      String planId,
      ) async {
    if (planId.trim().isEmpty) {
      return null;
    }

    final document = await _plansCollection(gymId)
        .doc(planId)
        .get();

    if (!document.exists) {
      return null;
    }

    return MembershipPlanModel.fromFirestore(
      document,
    );
  }

  Future<void> updateMembershipPlan(
      MembershipPlanModel plan,
      ) async {
    if (plan.gymId.trim().isEmpty) {
      throw ArgumentError(
        'Gym ID cannot be empty.',
      );
    }

    if (plan.id.trim().isEmpty) {
      throw ArgumentError(
        'Membership plan ID cannot be empty.',
      );
    }

    await _plansCollection(plan.gymId)
        .doc(plan.id)
        .set(
      plan.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteMembershipPlan(
      String gymId,
      String planId,
      ) async {
    if (planId.trim().isEmpty) {
      throw ArgumentError(
        'Membership plan ID cannot be empty.',
      );
    }

    await _plansCollection(gymId)
        .doc(planId)
        .delete();
  }

  Future<bool> hasMembersUsingPlan(
      String gymId,
      String planId,
      ) async {
    if (gymId.trim().isEmpty ||
        planId.trim().isEmpty) {
      return false;
    }

    final snapshot = await _firestore
        .collection('users')
        .where(
      'membershipPlanId',
      isEqualTo: planId,
    )
        .get();

    for (final document in snapshot.docs) {
      final data = document.data();

      final memberGymId =
      data['gymId'] as String?;

      if (memberGymId == gymId) {
        return true;
      }
    }

    return false;
  }
}