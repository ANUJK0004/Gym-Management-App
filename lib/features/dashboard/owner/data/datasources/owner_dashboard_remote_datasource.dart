import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/owner_dashboard_stats_model.dart';

class OwnerDashboardRemoteDataSource {
  OwnerDashboardRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<OwnerDashboardStatsModel> getDashboardStats({
    required String gymId,
  }) async {
    final totalMembersQuery = _firestore
        .collection('users')
        .where(
      'gymId',
      isEqualTo: gymId,
    );

    final activeTrainersQuery = _firestore
        .collection('trainers')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'status',
      isEqualTo: 'active',
    );

    final now = DateTime.now();

    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final newMembersQuery = _firestore
        .collection('users')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'joinedAt',
      isGreaterThanOrEqualTo:
      Timestamp.fromDate(
        startOfMonth,
      ),
    );

    final results = await Future.wait([
      totalMembersQuery.count().get(),
      activeTrainersQuery.count().get(),
      newMembersQuery.count().get(),
    ]);

    return OwnerDashboardStatsModel(
      totalMembers: results[0].count??0,
      activeTrainers: results[1].count??0,
      newMembersThisMonth: results[2].count??0,
      monthlyRevenue: 0,
    );
  }
}