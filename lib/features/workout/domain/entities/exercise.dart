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

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? muscleGroup,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    int? order,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      order: order ?? this.order,
    );
  }
}