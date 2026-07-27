class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.muscleGroup,
    this.sets = 0,
    this.reps = 0,
    this.weight,
    this.restSeconds,
    this.order = 0,
  });

  final String id;
  final String name;

  final String? description;
  final String? imageUrl;
  final String? muscleGroup;

  final int sets;
  final int reps;

  final double? weight;

  final int? restSeconds;

  final int order;
}