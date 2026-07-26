import '../entities/membership.dart';

abstract class MembershipRepository {
  Future<List<Membership>> getUserMemberships(
      String userId,
      );

  Future<Membership?> getMembership(
      String membershipId,
      );
}