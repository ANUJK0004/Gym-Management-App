import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workout.dart';
import 'exercise_model.dart';

class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    super.imageUrl,
    super.difficulty,
    super.duration,
    super.assignedDate,
    super.day,
    super.exercises,
  });

  factory WorkoutModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document, {
        List<ExerciseModel> exercises = const [],
      }) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Workout document does not exist.',
      );
    }

    return WorkoutModel(
      id: document.id,
      userId:
      data['userId'] as String? ?? '',
      name:
      data['name'] as String? ?? '',
      description:
      data['description'] as String? ?? '',
      imageUrl:
      data['imageUrl'] as String?,
      difficulty:
      data['difficulty'] as String?,
      duration:
      data['duration'] as int? ?? 0,
      assignedDate:
      _parseDate(data['assignedDate']),
      day:
      data['day'] as String? ?? 'Everyday',
      exercises: exercises,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'duration': duration,
      'day': day ?? 'Everyday',
      'assignedDate':
      assignedDate != null
          ? Timestamp.fromDate(
        assignedDate!,
      )
          : null,
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