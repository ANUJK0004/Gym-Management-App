import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_management_model.dart';

class MemberManagementRemoteDataSource {
  MemberManagementRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _usersCollection {
    return _firestore.collection('users');
  }

  // ----------------------------------------------------------
  // GET MEMBERS OF A GYM
  // ----------------------------------------------------------

  Future<List<MemberManagementModel>>
  getMembersByGymId(
      String gymId,
      ) async {
    final querySnapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'member',
    )
        .get();

    return querySnapshot.docs
        .map(
      MemberManagementModel
          .fromFirestore,
    )
        .toList();
  }

  // ----------------------------------------------------------
  // GET SINGLE MEMBER
  // ----------------------------------------------------------

  Future<MemberManagementModel?>
  getMemberById(
      String uid,
      ) async {
    final document =
    await _usersCollection
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null ||
        data['role'] != 'member') {
      return null;
    }

    return MemberManagementModel
        .fromFirestore(document);
  }

  // ----------------------------------------------------------
  // SEARCH ELIGIBLE MEMBERS
  // ----------------------------------------------------------

  Future<List<MemberManagementModel>> searchMembers({
    required String query,
    required String gymId,
  }) async {
    final normalizedQuery =
    query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final currentGymSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'member',
    )
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .get();

    final unassignedSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'member',
    )
        .get();

    final Map<String, MemberManagementModel>
    members = {};

    for (final document
    in currentGymSnapshot.docs) {
      final member =
      MemberManagementModel.fromFirestore(
        document,
      );

      members[member.uid] = member;
    }

    for (final document
    in unassignedSnapshot.docs) {
      final member =
      MemberManagementModel.fromFirestore(
        document,
      );

      if (!member.isAssignedToGym) {
        members[member.uid] = member;
      }
    }

    return members.values.where(
          (member) {
        final name =
            member.displayName
                ?.toLowerCase() ??
                '';

        final email =
        member.email.toLowerCase();

        final phone =
            member.phone
                ?.toLowerCase() ??
                '';

        return name.contains(
          normalizedQuery,
        ) ||
            email.contains(
              normalizedQuery,
            ) ||
            phone.contains(
              normalizedQuery,
            );
      },
    ).toList();
  }

  // ----------------------------------------------------------
  // FIND MEMBER BY EXACT EMAIL
  // ----------------------------------------------------------

  Future<MemberManagementModel?>
  findEligibleMemberByEmail({
    required String email,
    required String gymId,
  }) async {
    final normalizedEmail =
    email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return null;
    }

    // --------------------------------------------------------
    // First check members belonging to this gym.
    // --------------------------------------------------------

    final gymSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'member',
    )
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'email',
      isEqualTo: normalizedEmail,
    )
        .limit(1)
        .get();

    if (gymSnapshot.docs.isNotEmpty) {
      return MemberManagementModel
          .fromFirestore(
        gymSnapshot.docs.first,
      );
    }

    // --------------------------------------------------------
    // Then check members with no gym.
    // --------------------------------------------------------

    final unassignedSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'member',
    )
        .where(
      'gymId',
      isNull: true,
    )
        .where(
      'email',
      isEqualTo: normalizedEmail,
    )
        .limit(1)
        .get();

    if (unassignedSnapshot.docs.isNotEmpty) {
      return MemberManagementModel
          .fromFirestore(
        unassignedSnapshot.docs.first,
      );
    }

    // --------------------------------------------------------
    // IMPORTANT:
    //
    // We deliberately do not query another gym's member
    // and return that information.
    //
    // The future secure account-lookup Cloud Function
    // will handle "account exists but belongs elsewhere"
    // as a separate backend result.
    // --------------------------------------------------------

    return null;
  }

  // ----------------------------------------------------------
  // ASSIGN MEMBER TO GYM
  // ----------------------------------------------------------

  Future<void> assignMemberToGym({
    required String uid,
    required String gymId,
  }) async {
    final memberReference =
    _usersCollection.doc(uid);

    await _firestore.runTransaction(
          (transaction) async {
        final document =
        await transaction.get(
          memberReference,
        );

        if (!document.exists) {
          throw Exception(
            'Member account not found.',
          );
        }

        final data =
        document.data();

        if (data == null) {
          throw Exception(
            'Member profile not found.',
          );
        }

        final role =
        data['role'] as String?;

        if (role != 'member') {
          throw Exception(
            'This account is not registered '
                'as a member.',
          );
        }

        final existingGymId =
        data['gymId'] as String?;

        if (existingGymId != null &&
            existingGymId.isNotEmpty) {
          if (existingGymId == gymId) {
            throw Exception(
              'This member is already assigned '
                  'to this gym.',
            );
          }

          throw Exception(
            'This member is already assigned '
                'to another gym.',
          );
        }

        transaction.update(
          memberReference,
          {
            'gymId': gymId,

            'joinedAt':
            FieldValue.serverTimestamp(),

            'membershipStatus':
            'pending',

            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
// ASSIGN MEMBERSHIP PLAN
// ----------------------------------------------------------

  Future<void> assignMembershipPlan({
    required String uid,
    required String gymId,
    required String planId,
  }) async {
    final memberReference =
    _firestore
        .collection('users')
        .doc(uid);

    final planReference =
    _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membershipPlans')
        .doc(planId);

    await _firestore.runTransaction(
          (transaction) async {
        // ----------------------------------------------------
        // READS MUST HAPPEN BEFORE WRITES
        // ----------------------------------------------------

        final memberSnapshot =
        await transaction.get(
          memberReference,
        );

        final planSnapshot =
        await transaction.get(
          planReference,
        );

        if (!memberSnapshot.exists) {
          throw Exception(
            'Member account not found.',
          );
        }

        if (!planSnapshot.exists) {
          throw Exception(
            'Membership plan not found.',
          );
        }

        final memberData =
        memberSnapshot.data();

        final planData =
        planSnapshot.data();

        if (memberData == null ||
            planData == null) {
          throw Exception(
            'Unable to read membership data.',
          );
        }

        // ----------------------------------------------------
        // VERIFY MEMBER BELONGS TO THIS GYM
        // ----------------------------------------------------

        final memberGymId =
        memberData['gymId'] as String?;

        if (memberGymId != gymId) {
          throw Exception(
            'Member does not belong to this gym.',
          );
        }

        // ----------------------------------------------------
        // VERIFY PLAN BELONGS TO THIS GYM
        // ----------------------------------------------------

        final planGymId =
        planData['gymId'] as String?;

        if (planGymId != gymId) {
          throw Exception(
            'Membership plan does not belong '
                'to this gym.',
          );
        }

        // ----------------------------------------------------
        // VERIFY PLAN IS ACTIVE
        // ----------------------------------------------------

        final isActive =
            planData['isActive'] as bool? ?? true;

        if (!isActive) {
          throw Exception(
            'This membership plan is inactive.',
          );
        }

        // ----------------------------------------------------
        // READ DURATION
        // ----------------------------------------------------

        final duration =
            (planData['durationInDays'] as num?)
                ?.toInt() ??
                0;

        if (duration <= 0) {
          throw Exception(
            'Membership plan has an invalid duration.',
          );
        }

        // ----------------------------------------------------
        // CALCULATE MEMBERSHIP PERIOD
        // ----------------------------------------------------

        final startedAt =
        DateTime.now();

        final expiresAt =
        startedAt.add(
          Duration(
            days: duration,
          ),
        );

        // ----------------------------------------------------
        // UPDATE MEMBER
        // ----------------------------------------------------

        transaction.update(
          memberReference,
          {
            'membershipPlanId':
            planId,

            'membershipStatus':
            'active',

            'membershipStartedAt':
            Timestamp.fromDate(
              startedAt,
            ),

            'membershipExpiresAt':
            Timestamp.fromDate(
              expiresAt,
            ),
          },
        );
      },
    );
  }

// ----------------------------------------------------------
// REMOVE MEMBERSHIP PLAN
// ----------------------------------------------------------

  Future<void> removeMembershipPlan(
      String uid,
      ) async {
    final memberReference =
    _firestore
        .collection('users')
        .doc(uid);

    await memberReference.update({
      'membershipPlanId':
      FieldValue.delete(),

      'membershipStatus':
      FieldValue.delete(),

      'membershipStartedAt':
      FieldValue.delete(),

      'membershipExpiresAt':
      FieldValue.delete(),
    });
  }
  // ----------------------------------------------------------
  // REMOVE MEMBER FROM GYM
  // ----------------------------------------------------------

  Future<void> removeMemberFromGym(
      String uid,
      ) async {
    final memberReference =
    _usersCollection.doc(uid);

    final document =
    await memberReference.get();

    if (!document.exists) {
      throw Exception(
        'Member account not found.',
      );
    }

    final data =
    document.data();

    if (data == null) {
      throw Exception(
        'Member profile not found.',
      );
    }

    if (data['role'] != 'member') {
      throw Exception(
        'This account is not a member.',
      );
    }

    await memberReference.update({
      'gymId':
      FieldValue.delete(),

      'joinedAt':
      FieldValue.delete(),

      'membershipPlanId':
      FieldValue.delete(),

      'membershipStatus':
      FieldValue.delete(),

      'membershipStartedAt':
      FieldValue.delete(),

      'membershipExpiresAt':
      FieldValue.delete(),
    });
  }
}