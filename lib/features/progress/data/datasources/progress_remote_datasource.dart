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

    final results = await Future.wait([
      progressReference.get(),

      progressReference
          .collection('weekly_activity')
          .orderBy('order')
          .limit(7)
          .get(),

      progressReference
          .collection('personal_records')
          .orderBy(
        'date',
        descending: true,
      )
          .limit(10)
          .get(),
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

    final activityMap = <String, WeeklyActivityModel>{};

    for (final document
    in activitySnapshot.docs) {
      final activity =
      WeeklyActivityModel.fromFirestore(
        document,
      );

      activityMap[activity.day] =
          activity;
    }

    final weeklyActivity =
    _buildWeeklyActivity(
      activityMap,
    );

    final personalRecords =
    recordsSnapshot.docs
        .map(
      PersonalRecordModel
          .fromFirestore,
    )
        .toList();

    if (!progressDocument.exists) {
      return ProgressModel.empty(
        userId: userId,
        weeklyActivity:
        weeklyActivity,
        personalRecords:
        personalRecords,
      );
    }

    return ProgressModel.fromFirestore(
      progressDocument,
      weeklyActivity:
      weeklyActivity,
      personalRecords:
      personalRecords,
    );
  }

  List<WeeklyActivityModel>
  _buildWeeklyActivity(
      Map<String, WeeklyActivityModel>
      activityMap,
      ) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return List.generate(
      7,
          (index) {
        final day = days[index];

        return activityMap[day] ??
            WeeklyActivityModel(
              day: day,
              workouts: 0,
            );
      },
    );
  }

  Future<void> updateBodyMetrics({
    required String userId,
    double? weight,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final progressReference =
    _firestore
        .collection('progress')
        .doc(userId);

    final snapshot =
    await progressReference.get();

    final oldData =
        snapshot.data() ?? {};

    final oldWeight =
        (oldData['currentWeight']
        as num?)
            ?.toDouble() ??
            0;

    final oldBodyFat =
        (oldData['bodyFat'] as num?)
            ?.toDouble() ??
            0;

    final oldMuscleMass =
        (oldData['muscleMass']
        as num?)
            ?.toDouble() ??
            0;

    await progressReference.set(
      {
        'userId': userId,

        'currentWeight': ?weight,

        'bodyFat': ?bodyFat,

        'muscleMass': ?muscleMass,

        if (weight != null)
          'weightChange':
          weight - oldWeight,

        if (bodyFat != null)
          'bodyFatChange':
          bodyFat - oldBodyFat,

        if (muscleMass != null)
          'muscleMassChange':
          muscleMass -
              oldMuscleMass,

        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }
}