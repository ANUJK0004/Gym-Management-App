import '../../domain/entities/membership_plan.dart';
import '../../domain/repositories/membership_plan_repository.dart';

import '../datasources/membership_plan_remote_datasource.dart';
import '../models/membership_plan_model.dart';

class MembershipPlanRepositoryImpl
    implements MembershipPlanRepository {
  MembershipPlanRepositoryImpl(
      this._dataSource,
      );

  final MembershipPlanRemoteDataSource _dataSource;

  @override
  Future<MembershipPlan> createMembershipPlan(
      MembershipPlan plan,
      ) {
    final model = MembershipPlanModel(
      id: plan.id,
      gymId: plan.gymId,
      name: plan.name,
      price: plan.price,
      durationInDays: plan.durationInDays,
      description: plan.description,
      isActive: plan.isActive,
      createdAt: plan.createdAt,
    );

    return _dataSource.createMembershipPlan(model);
  }

  @override
  Future<List<MembershipPlan>> getMembershipPlans(
      String gymId,
      ) {
    return _dataSource.getMembershipPlans(gymId);
  }

  @override
  Future<MembershipPlan?> getMembershipPlan(
      String gymId,
      String planId,
      ) {
    return _dataSource.getMembershipPlan(
      gymId,
      planId,
    );
  }

  @override
  Future<void> updateMembershipPlan(
      MembershipPlan plan,
      ) {
    final model = MembershipPlanModel(
      id: plan.id,
      gymId: plan.gymId,
      name: plan.name,
      price: plan.price,
      durationInDays: plan.durationInDays,
      description: plan.description,
      isActive: plan.isActive,
      createdAt: plan.createdAt,
    );

    return _dataSource.updateMembershipPlan(model);
  }

  @override
  Future<void> deleteMembershipPlan(
      String gymId,
      String planId,
      ) {
    return _dataSource.deleteMembershipPlan(
      gymId,
      planId,
    );
  }

  @override
  Future<bool> hasMembersUsingPlan(
      String gymId,
      String planId,
      ) {
    return _dataSource.hasMembersUsingPlan(
      gymId,
      planId,
    );
  }
}