import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/trainer_enrollment_model.dart';

class TrainerEnrollmentRemoteDataSource {
  TrainerEnrollmentRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore =
      firestore ??
          FirebaseFirestore.instance,
        _functions =
            functions ??
                FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>>
  get _collection {
    return _firestore.collection(
      'trainerEnrollments',
    );
  }

  Future<TrainerEnrollmentModel>
  createEnrollment({
    required String gymId,
    required String displayName,
    required String email,
    required double monthlySalary,
    required DateTime startDate,
    String? specialization,
  }) async {
    final callable =
    _functions.httpsCallable(
      'createTrainerEnrollment',
    );

    final result =
    await callable.call({
      'gymId': gymId,
      'displayName':
      displayName.trim(),
      'email':
      email.trim().toLowerCase(),
      'monthlySalary':
      monthlySalary,
      'startDate':
      startDate.toIso8601String(),
      'specialization':
      specialization,
    });

    final enrollmentId =
    result.data['enrollmentId'] as String;

    final document =
    await _collection
        .doc(enrollmentId)
        .get();

    return TrainerEnrollmentModel
        .fromFirestore(document);
  }

  Future<TrainerEnrollmentModel?>
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

    return TrainerEnrollmentModel
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