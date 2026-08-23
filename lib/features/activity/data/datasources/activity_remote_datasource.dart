import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/activity_log.dart';
import '../models/activity_log_model.dart';

class ActivityRemoteDataSource {
  ActivityRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Stream<List<ActivityLogModel>> streamRecentActivities({
    required String gymId,
    int limit = 20,
  }) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('activityLogs')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ActivityLogModel.fromFirestore)
              .toList(),
        );
  }

  Future<List<ActivityLogModel>> getRecentActivities({
    required String gymId,
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('activityLogs')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .limit(limit)
        .get();

    return snapshot.docs
        .map(ActivityLogModel.fromFirestore)
        .toList();
  }

  Future<void> createActivity(
      ActivityLog activity,
      ) async {
    final collection = _firestore
        .collection('gyms')
        .doc(activity.gymId)
        .collection('activityLogs');

    final docRef = activity.id.trim().isNotEmpty
        ? collection.doc(activity.id)
        : collection.doc();

    final activityWithId = ActivityLog(
      id: docRef.id,
      gymId: activity.gymId,
      title: activity.title,
      description: activity.description,
      type: activity.type,
      actorId: activity.actorId,
      actorName: activity.actorName,
      actorRole: activity.actorRole,
      targetId: activity.targetId,
      targetName: activity.targetName,
      targetType: activity.targetType,
      createdAt: activity.createdAt,
      metadata: activity.metadata,
    );

    final model = ActivityLogModel.fromEntity(activityWithId);

    await docRef.set(model.toFirestore());
  }
}