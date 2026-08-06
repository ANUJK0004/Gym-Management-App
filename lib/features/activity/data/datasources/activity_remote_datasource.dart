import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/activity_log.dart';
import '../models/activity_log_model.dart';

class ActivityRemoteDataSource {
  ActivityRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<List<ActivityLogModel>>
  getRecentActivities({
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
    final model = ActivityLogModel.fromEntity(activity);

    await _firestore
        .collection('gyms')
        .doc(activity.gymId)
        .collection('activityLogs')
        .doc(activity.id)
        .set(model.toFirestore());
  }
}