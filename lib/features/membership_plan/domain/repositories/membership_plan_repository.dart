import '../entities/membership_plan.dart';

abstract class MembershipPlanRepository {
  Future<MembershipPlan> createMembershipPlan(
      MembershipPlan plan,
      );

  Future<List<MembershipPlan>> getMembershipPlans(
      String gymId,
      );

  Future<MembershipPlan?> getMembershipPlan(
      String gymId,
      String planId,
      );

  Future<void> updateMembershipPlan(
      MembershipPlan plan,
      );

  Future<void> deleteMembershipPlan(
      String gymId,
      String planId,
      );

  Future<bool> hasMembersUsingPlan(
      String gymId,
      String planId,
      );
}