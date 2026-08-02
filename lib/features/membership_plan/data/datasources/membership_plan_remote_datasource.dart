import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/membership_plan_model.dart';

class MembershipPlanRemoteDataSource {
  MembershipPlanRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  _plansCollection(
      String gymId,
      ) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membershipPlans');
  }

  Future<MembershipPlanModel> createMembershipPlan(
      MembershipPlanModel plan,
      ) async {
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
      durationInDays:
      plan.durationInDays,
      description:
      plan.description,
      isActive:
      plan.isActive,
      createdAt:
      plan.createdAt,
    );
  }

  Future<List<MembershipPlanModel>>
  getMembershipPlans(
      String gymId,
      ) async {
    final querySnapshot =
    await _plansCollection(gymId)
        .orderBy(
      'createdAt',
      descending: true,
    )
        .get();

    return querySnapshot.docs
        .map(
      MembershipPlanModel
          .fromFirestore,
    )
        .toList();
  }

  Future<MembershipPlanModel?>
  getMembershipPlan(
      String gymId,
      String planId,
      ) async {
    final document =
    await _plansCollection(gymId)
        .doc(planId)
        .get();

    if (!document.exists) {
      return null;
    }

    return MembershipPlanModel
        .fromFirestore(
      document,
    );
  }

  Future<void> updateMembershipPlan(
      MembershipPlanModel plan,
      ) async {
    await _plansCollection(
      plan.gymId,
    )
        .doc(plan.id)
        .set(
      plan.toFirestore(),
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<void> deleteMembershipPlan(
      String gymId,
      String planId,
      ) async {
    await _plansCollection(gymId)
        .doc(planId)
        .delete();
  }
}