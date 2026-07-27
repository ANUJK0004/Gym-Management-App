import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.muscleGroup,
    super.sets,
    super.reps,
    super.weight,
    super.restSeconds,
    super.order,
  });

  factory ExerciseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Exercise document does not exist.',
      );
    }

    return ExerciseModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      description:
      data['description'] as String?,
      imageUrl:
      data['imageUrl'] as String?,
      muscleGroup:
      data['muscleGroup'] as String?,
      sets:
      data['sets'] as int? ?? 0,
      reps:
      data['reps'] as int? ?? 0,
      weight:
      (data['weight'] as num?)?.toDouble(),
      restSeconds:
      data['restSeconds'] as int?,
      order:
      data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'order': order,
    };
  }
}