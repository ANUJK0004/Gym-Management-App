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

    final financeTransactionsFuture =
    _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('financeTransactions')
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
      financeTransactionsFuture,
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

    final financeTransactions =
        (results[4]
        as QuerySnapshot)
            .docs;

    //-------------------------------------------------------
    // STEP 5
    // Membership & Revenue statistics
    //-------------------------------------------------------

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month; // 1-12
    final List<double> monthlyRevenueTrend = List.filled(12, 0.0);

    int activeMembers = 0;
    int expiredMembers = 0;
    int pendingMembers = 0;

    double membershipRevenue = 0;

    for (final doc in memberships) {
      final data =
      doc.data()
      as Map<String, dynamic>;

      final status =
      (data['status'] ?? '')
          .toString()
          .toLowerCase();

      final amount =
          (data['amount'] as num?)?.toDouble() ?? 0.0;

      switch (status) {
        case 'active':
          activeMembers++;
          membershipRevenue += amount;
          break;

        case 'expired':
          expiredMembers++;
          break;

        default:
          pendingMembers++;
      }

      final timestamp = data['startDate'] as Timestamp? ??
          data['createdAt'] as Timestamp?;

      if (timestamp != null) {
        final date = timestamp.toDate();
        if (date.year == currentYear && date.month >= 1 && date.month <= 12) {
          monthlyRevenueTrend[date.month - 1] += amount;
        }
      } else if (status == 'active') {
        monthlyRevenueTrend[currentMonth - 1] += amount;
      }
    }

    double transactionRevenue = 0;
    for (final doc in financeTransactions) {
      final data = doc.data() as Map<String, dynamic>;
      final type = (data['type'] ?? '').toString().toLowerCase();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final timestamp = data['date'] as Timestamp?;

      if (type == 'income' || type == 'revenue' || type.isEmpty) {
        transactionRevenue += amount;
        if (timestamp != null) {
          final date = timestamp.toDate();
          if (date.year == currentYear && date.month >= 1 && date.month <= 12) {
            monthlyRevenueTrend[date.month - 1] += amount;
          }
        } else {
          monthlyRevenueTrend[currentMonth - 1] += amount;
        }
      }
    }

    double currentMonthRevenue = monthlyRevenueTrend[currentMonth - 1];
    if (currentMonthRevenue == 0 && (membershipRevenue > 0 || transactionRevenue > 0)) {
      currentMonthRevenue = membershipRevenue > 0 ? membershipRevenue : transactionRevenue;
      monthlyRevenueTrend[currentMonth - 1] = currentMonthRevenue;
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
      currentMonthRevenue,

      monthlyRevenueTrend:
      monthlyRevenueTrend,
    );
  }
}