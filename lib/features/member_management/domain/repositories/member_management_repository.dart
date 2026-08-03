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

  /// Searches existing member accounts.
  Future<List<ManagedMember>> searchMembers(
      String query,
      );

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