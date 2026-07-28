import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/progress.dart';

class ProgressModel extends Progress {
  const ProgressModel({
    required super.userId,
    required super.currentWeight,
    required super.bodyFat,
    required super.muscleMass,
    required super.totalWorkouts,
    super.weightChange,
    super.bodyFatChange,
    super.muscleMassChange,
    super.workoutChange,
    super.weeklyActivity,
    super.personalRecords,
  });

  factory ProgressModel.empty({
    required String userId,
    List<WeeklyActivity> weeklyActivity =
    const [],
    List<PersonalRecord> personalRecords =
    const [],
  }) {
    return ProgressModel(
      userId: userId,
      currentWeight: 0,
      bodyFat: 0,
      muscleMass: 0,
      totalWorkouts: 0,
      weeklyActivity: weeklyActivity,
      personalRecords: personalRecords,
    );
  }

  factory ProgressModel.fromFirestore(
      DocumentSnapshot<
          Map<String, dynamic>>
      document, {
        List<WeeklyActivity> weeklyActivity =
        const [],
        List<PersonalRecord> personalRecords =
        const [],
      }) {
    final data = document.data();

    if (data == null) {
      return ProgressModel.empty(
        userId: document.id,
        weeklyActivity:
        weeklyActivity,
        personalRecords:
        personalRecords,
      );
    }

    return ProgressModel(
      userId:
      data['userId'] as String? ??
          document.id,

      currentWeight:
      (data['currentWeight'] as num?)
          ?.toDouble() ??
          0,

      bodyFat:
      (data['bodyFat'] as num?)
          ?.toDouble() ??
          0,

      muscleMass:
      (data['muscleMass'] as num?)
          ?.toDouble() ??
          0,

      totalWorkouts:
      (data['totalWorkouts'] as num?)
          ?.toInt() ??
          0,

      weightChange:
      (data['weightChange'] as num?)
          ?.toDouble() ??
          0,

      bodyFatChange:
      (data['bodyFatChange'] as num?)
          ?.toDouble() ??
          0,

      muscleMassChange:
      (data['muscleMassChange'] as num?)
          ?.toDouble() ??
          0,

      workoutChange:
      (data['workoutChange'] as num?)
          ?.toInt() ??
          0,

      weeklyActivity:
      weeklyActivity,

      personalRecords:
      personalRecords,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentWeight':
      currentWeight,
      'bodyFat': bodyFat,
      'muscleMass':
      muscleMass,
      'totalWorkouts':
      totalWorkouts,
      'weightChange':
      weightChange,
      'bodyFatChange':
      bodyFatChange,
      'muscleMassChange':
      muscleMassChange,
      'workoutChange':
      workoutChange,
      'updatedAt':
      FieldValue.serverTimestamp(),
    };
  }
}

class WeeklyActivityModel
    extends WeeklyActivity {
  const WeeklyActivityModel({
    required super.day,
    required super.workouts,
  });

  factory WeeklyActivityModel
      .fromFirestore(
      DocumentSnapshot<
          Map<String, dynamic>>
      document,
      ) {
    final data =
        document.data() ?? {};

    return WeeklyActivityModel(
      day:
      data['day'] as String? ??
          '',
      workouts:
      (data['workouts'] as num?)
          ?.toInt() ??
          0,
    );
  }
}

class PersonalRecordModel
    extends PersonalRecord {
  const PersonalRecordModel({
    required super.id,
    required super.exerciseName,
    required super.weight,
    required super.date,
  });

  factory PersonalRecordModel
      .fromFirestore(
      DocumentSnapshot<
          Map<String, dynamic>>
      document,
      ) {
    final data =
        document.data() ?? {};

    final timestamp =
    data['date'] as Timestamp?;

    return PersonalRecordModel(
      id: document.id,
      exerciseName:
      data['exerciseName']
      as String? ??
          '',
      weight:
      (data['weight'] as num?)
          ?.toDouble() ??
          0,
      date:
      timestamp?.toDate() ??
          DateTime.now(),
    );
  }
}