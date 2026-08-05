import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/owner_dashboard_data_model.dart';

class OwnerDashboardRemoteDataSource {
  OwnerDashboardRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<OwnerDashboardDataModel> getDashboard({
    required String ownerId,
  }) async {

    //-------------------------------------------------------
    // STEP 1
    // Fetch owner document
    //-------------------------------------------------------

    final ownerSnapshot = await _firestore
        .collection('users')
        .doc(ownerId)
        .get();

    if (!ownerSnapshot.exists) {
      throw Exception('Owner not found.');
    }

    final owner =
    ownerSnapshot.data()!;

    final gymId =
    owner['gymId'] as String?;

    if (gymId == null || gymId.isEmpty) {
      throw Exception(
        'Owner has no assigned gym.',
      );
    }

    //-------------------------------------------------------
    // STEP 2
    // Fetch Gym
    //-------------------------------------------------------

    final gymSnapshot = await _firestore
        .collection('gyms')
        .doc(gymId)
        .get();

    if (!gymSnapshot.exists) {
      throw Exception(
        'Gym not found.',
      );
    }

    final gym =
    gymSnapshot.data()!;

    //-------------------------------------------------------
    // STEP 3
    // Firestore requests in parallel
    //-------------------------------------------------------

    // final now = DateTime.now();

    // final startOfMonth =
    // DateTime(
    //   now.year,
    //   now.month,
    //   1,
    // );

    final totalMembersFuture =
    _firestore
        .collection('users')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'member',
    )
        .count()
        .get();

    final trainersFuture =
    _firestore
        .collection('users')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .count()
        .get();

    final newMembersFuture =
    _firestore
        .collection('users')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'member',
    )
    //     .where(
    //   'joinedAt',
    //   isGreaterThanOrEqualTo:
    //   Timestamp.fromDate(
    //     startOfMonth,
    //   ),
    // )
        .count()
        .get();

    final membershipsFuture =
    _firestore
        .collection('memberships')
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .get();

    //-------------------------------------------------------
    // STEP 4
    //-------------------------------------------------------

    final results =
    await Future.wait([
      totalMembersFuture,
      trainersFuture,
      newMembersFuture,
      membershipsFuture,
    ]);

    final totalMembers =
        (results[0]
        as AggregateQuerySnapshot)
            .count;

    final activeTrainers =
        (results[1]
        as AggregateQuerySnapshot)
            .count;

    final newMembers =
        (results[2]
        as AggregateQuerySnapshot)
            .count;

    final memberships =
        (results[3]
        as QuerySnapshot)
            .docs;

    //-------------------------------------------------------
    // STEP 5
    // Membership statistics
    //-------------------------------------------------------

    int activeMembers = 0;
    int expiredMembers = 0;
    int pendingMembers = 0;

    double revenue = 0;

    for (final doc in memberships) {
      final data =
      doc.data()
      as Map<String, dynamic>;

      final status =
      (data['status'] ?? '')
          .toString()
          .toLowerCase();

      switch (status) {
        case 'active':
          activeMembers++;
          break;

        case 'expired':
          expiredMembers++;
          break;

        default:
          pendingMembers++;
      }

      revenue +=
          (data['amount']
          as num?)
              ?.toDouble() ??
              0;
    }

    //-------------------------------------------------------
    // STEP 6
    //-------------------------------------------------------

    return OwnerDashboardDataModel(
      ownerId: ownerId,

      ownerName:
      owner['displayName'] ??
          '',

      ownerEmail:
      owner['email'] ??
          '',

      ownerPhotoUrl:
      owner['photoUrl'],

      gymId: gymId,

      gymName:
      gym['name'] ?? '',

      gymAddress:
      gym['address'] ?? '',

      gymPhone:
      gym['phone'],

      gymEmail:
      gym['email'] ?? '',

      gymDescription:
      gym['description'] ??
          '',

      gymLogoUrl:
      gym['logoUrl'],

      totalMembers:
      totalMembers!,

      activeMembers:
      activeMembers,

      expiredMembers:
      expiredMembers,

      pendingMembers:
      pendingMembers,

      activeTrainers:
      activeTrainers!,

      newMembersThisMonth:
      newMembers??0,

      monthlyRevenue:
      revenue,
    );
  }
}