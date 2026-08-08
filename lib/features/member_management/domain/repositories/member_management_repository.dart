import '../entities/managed_member.dart';

abstract class MemberManagementRepository {
  Future<List<ManagedMember>> getMembersByGymId(
      String gymId,
      );

  Future<ManagedMember?> getMemberById(
      String uid,
      );

  Future<List<ManagedMember>> searchMembers({
    required String query,
    required String gymId,
  });

  Future<ManagedMember?> findEligibleMemberByEmail({
    required String email,
    required String gymId,
  });

  Future<void> assignMemberToGym({
    required String uid,
    required String gymId,
  });

  Future<void> removeMemberFromGym(
      String uid,
      );

  // ----------------------------------------------------------
  // MEMBERSHIP
  // ----------------------------------------------------------

  Future<void> assignMembershipPlan({
    required String uid,
    required String gymId,
    required String planId,
  });

  Future<void> removeMembershipPlan(
      String uid,
      );
}