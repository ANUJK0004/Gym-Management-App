import '../../domain/entities/managed_member.dart';
import '../../domain/repositories/member_management_repository.dart';

import '../datasources/member_management_remote_datasource.dart';

class MemberManagementRepositoryImpl
    implements MemberManagementRepository {
  MemberManagementRepositoryImpl(
      this._dataSource,
      );

  final MemberManagementRemoteDataSource
  _dataSource;

  @override
  Future<List<ManagedMember>>
  getMembersByGymId(
      String gymId,
      ) {
    return _dataSource.getMembersByGymId(
      gymId,
    );
  }

  @override
  Future<ManagedMember?>
  getMemberById(
      String uid,
      ) {
    return _dataSource.getMemberById(
      uid,
    );
  }

  @override
  Future<List<ManagedMember>>
  searchMembers({
    required String query,
    required String gymId,
  }) {
    return _dataSource.searchMembers(
      query: query,
      gymId: gymId,
    );
  }

  @override
  Future<ManagedMember?>
  findEligibleMemberByEmail({
    required String email,
    required String gymId,
  }) {
    return _dataSource.findEligibleMemberByEmail(
      email: email,
      gymId: gymId,
    );
  }

  @override
  Future<void>
  assignMemberToGym({
    required String uid,
    required String gymId,
  }) {
    return _dataSource.assignMemberToGym(
      uid: uid,
      gymId: gymId,
    );
  }

  @override
  Future<void>
  removeMemberFromGym(
      String uid,
      ) {
    return _dataSource.removeMemberFromGym(
      uid,
    );
  }

  // ----------------------------------------------------------
  // MEMBERSHIP
  // ----------------------------------------------------------

  @override
  Future<void>
  assignMembershipPlan({
    required String uid,
    required String gymId,
    required String planId,
  }) {
    return _dataSource.assignMembershipPlan(
      uid: uid,
      gymId: gymId,
      planId: planId,
    );
  }

  @override
  Future<void>
  removeMembershipPlan(
      String uid,
      ) {
    return _dataSource.removeMembershipPlan(
      uid,
    );
  }
}