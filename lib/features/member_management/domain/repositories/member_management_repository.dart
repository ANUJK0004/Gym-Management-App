import '../entities/managed_member.dart';

abstract class MemberManagementRepository {
  /// Gets all members assigned to a particular gym.
  Future<List<ManagedMember>> getMembersByGymId(
      String gymId,
      );

  /// Gets a single member by UID.
  Future<ManagedMember?> getMemberById(
      String uid,
      );

  /// Searches members that are eligible to be
  /// managed by the specified gym.
  ///
  /// Results can belong to:
  /// - this gym
  /// - no gym
  ///
  /// Members belonging to another gym must
  /// never be returned.
  Future<List<ManagedMember>> searchMembers({
    required String query,
    required String gymId,
  });

  /// Finds an eligible member by exact email.
  ///
  /// Only returns:
  /// - member belonging to this gym
  /// - member not assigned to any gym
  ///
  /// It does not expose members belonging
  /// to another gym.
  Future<ManagedMember?> findEligibleMemberByEmail({
    required String email,
    required String gymId,
  });

  /// Assigns an existing member to a gym.
  Future<void> assignMemberToGym({
    required String uid,
    required String gymId,
  });

  /// Removes the member from the gym.
  Future<void> removeMemberFromGym(
      String uid,
      );
}