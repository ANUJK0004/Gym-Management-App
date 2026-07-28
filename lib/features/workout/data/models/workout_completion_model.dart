import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workout_completion.dart';

class WorkoutCompletionModel
    extends WorkoutCompletion {
  const WorkoutCompletionModel({
    required super.id,
    required super.userId,
    required super.workoutId,
    required super.completedAt,
    required super.duration,
    required super.completedExercises,
    required super.totalExercises,
  });

  factory WorkoutCompletionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Workout completion document does not exist.',
      );
    }

    return WorkoutCompletionModel(
      id: document.id,
      userId:
      data['userId'] as String? ?? '',
      workoutId:
      data['workoutId'] as String? ?? '',
      completedAt:
      _parseDate(data['completedAt']) ??
          DateTime.now(),
      duration:
      (data['duration'] as num?)?.toInt() ?? 0,
      completedExercises:
      (data['completedExercises'] as num?)
          ?.toInt() ??
          0,
      totalExercises:
      (data['totalExercises'] as num?)
          ?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'workoutId': workoutId,
      'completedAt':
      Timestamp.fromDate(completedAt),
      'duration': duration,
      'completedExercises':
      completedExercises,
      'totalExercises':
      totalExercises,
    };
  }

  static DateTime? _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}