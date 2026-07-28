import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_model.dart';

class ProgressRemoteDataSource {
  ProgressRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<ProgressModel> getProgress(
      String userId,
      ) async {
    final progressReference = _firestore
        .collection('progress')
        .doc(userId);

    final progressFuture =
    progressReference.get();

    final activityFuture =
    progressReference
        .collection('weekly_activity')
        .limit(7)
        .get();

    final recordsFuture =
    progressReference
        .collection('personal_records')
        .orderBy(
      'date',
      descending: true,
    )
        .limit(10)
        .get();

    final results = await Future.wait([
      progressFuture,
      activityFuture,
      recordsFuture,
    ]);

    final progressDocument =
    results[0]
    as DocumentSnapshot<
        Map<String, dynamic>>;

    final activitySnapshot =
    results[1]
    as QuerySnapshot<
        Map<String, dynamic>>;

    final recordsSnapshot =
    results[2]
    as QuerySnapshot<
        Map<String, dynamic>>;

    final weeklyActivity =
    activitySnapshot.docs
        .map(
      WeeklyActivityModel
          .fromFirestore,
    )
        .toList();

    final personalRecords =
    recordsSnapshot.docs
        .map(
      PersonalRecordModel
          .fromFirestore,
    )
        .toList();

    return ProgressModel.fromFirestore(
      progressDocument,
      weeklyActivity:
      weeklyActivity,
      personalRecords:
      personalRecords,
    );
  }
}