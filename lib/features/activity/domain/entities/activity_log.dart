class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.gymId,

    required this.title,
    required this.description,

    required this.type,

    required this.actorId,
    required this.actorName,
    required this.actorRole,

    this.targetId,
    this.targetName,
    this.targetType,

    required this.createdAt,

    this.metadata = const {},
  });

  final String id;

  final String gymId;

  final String title;

  final String description;

  final String type;

  final String actorId;

  final String actorName;

  final String actorRole;

  final String? targetId;

  final String? targetName;

  final String? targetType;

  final DateTime createdAt;

  final Map<String, dynamic> metadata;
}