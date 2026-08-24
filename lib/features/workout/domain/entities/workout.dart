import 'exercise.dart';

class Workout {
  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.imageUrl,
    this.difficulty,
    this.duration = 0,
    this.assignedDate,
    this.exercises = const [],
  });

  final String id;
  final String userId;

  final String name;
  final String description;

  final String? imageUrl;
  final String? difficulty;

  final int duration;

  final DateTime? assignedDate;

  final List<Exercise> exercises;

  int get exerciseCount => exercises.length;

  Workout copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? imageUrl,
    String? difficulty,
    int? duration,
    DateTime? assignedDate,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      assignedDate: assignedDate ?? this.assignedDate,
      exercises: exercises ?? this.exercises,
    );
  }
}