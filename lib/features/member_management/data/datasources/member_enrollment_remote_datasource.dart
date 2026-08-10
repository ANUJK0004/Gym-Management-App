import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/member_enrollment_model.dart';

class MemberEnrollmentRemoteDataSource {
  MemberEnrollmentRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore =
      firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>>
  get _collection {
    return _firestore.collection(
      'memberEnrollments',
    );
  }

  Future<MemberEnrollmentModel>
  createEnrollment({
    required String gymId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? fitnessGoal,
    required String membershipPlanId,
    required String membershipPlanName,
    required double amount,
    String? paymentMethod,
    required DateTime startDate,
  }) async {
    final callable =
    _functions.httpsCallable(
      'createMemberEnrollment',
    );

    final result =
    await callable.call({
      'gymId': gymId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,

      'dateOfBirth':
      dateOfBirth?.toIso8601String(),

      'gender': gender,
      'fitnessGoal': fitnessGoal,

      'membershipPlanId':
      membershipPlanId,

      'membershipPlanName':
      membershipPlanName,

      'amount': amount,

      'paymentMethod':
      paymentMethod,

      'startDate':
      startDate.toIso8601String(),
    });

    final enrollmentId =
    result.data['enrollmentId'] as String;

    final document =
    await _collection
        .doc(enrollmentId)
        .get();

    return MemberEnrollmentModel
        .fromFirestore(document);
  }

  Future<MemberEnrollmentModel?>
  getEnrollment(
      String enrollmentId,
      ) async {
    final document =
    await _collection
        .doc(enrollmentId)
        .get();

    if (!document.exists) {
      return null;
    }

    return MemberEnrollmentModel
        .fromFirestore(document);
  }

  Future<void> cancelEnrollment(
      String enrollmentId,
      ) async {
    await _collection
        .doc(enrollmentId)
        .update({
      'status': 'cancelled',
    });
  }
}