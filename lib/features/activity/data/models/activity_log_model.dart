import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/activity_log.dart';

class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    required super.id,
    required super.gymId,

    required super.title,
    required super.description,

    required super.type,

    required super.actorId,
    required super.actorName,
    required super.actorRole,

    super.targetId,
    super.targetName,
    super.targetType,

    required super.createdAt,

    super.metadata,
  });

  factory ActivityLogModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return ActivityLogModel(
      id: doc.id,

      gymId: data['gymId'] ?? '',

      title: data['title'] ?? '',

      description: data['description'] ?? '',

      type: data['type'] ?? '',

      actorId: data['actorId'] ?? '',

      actorName: data['actorName'] ?? '',

      actorRole: data['actorRole'] ?? '',

      targetId: data['targetId'],

      targetName: data['targetName'],

      targetType: data['targetType'],

      createdAt:
      (data['createdAt'] as Timestamp).toDate(),

      metadata: Map<String, dynamic>.from(
        data['metadata'] ?? {},
      ),
    );
  }

  /// Converts Domain Entity -> Firestore Model
  factory ActivityLogModel.fromEntity(
      ActivityLog entity,
      ) {
    return ActivityLogModel(
      id: entity.id,

      gymId: entity.gymId,

      title: entity.title,

      description: entity.description,

      type: entity.type,

      actorId: entity.actorId,

      actorName: entity.actorName,

      actorRole: entity.actorRole,

      targetId: entity.targetId,

      targetName: entity.targetName,

      targetType: entity.targetType,

      createdAt: entity.createdAt,

      metadata: entity.metadata,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,

      'gymId': gymId,

      'title': title,

      'description': description,

      'type': type,

      'actorId': actorId,

      'actorName': actorName,

      'actorRole': actorRole,

      'targetId': targetId,

      'targetName': targetName,

      'targetType': targetType,

      'createdAt': Timestamp.fromDate(createdAt),

      'metadata': metadata,
    };
  }
}