import '../../domain/entities/membership.dart';
import '../../domain/repositories/membership_repository.dart';
import '../datasources/membership_remote_datasource.dart';

class MembershipRepositoryImpl
    implements MembershipRepository {
  MembershipRepositoryImpl(
      this._dataSource,
      );

  final MembershipRemoteDataSource _dataSource;

  @override
  Future<List<Membership>> getUserMemberships(
      String userId,
      ) {
    return _dataSource.getUserMemberships(
      userId,
    );
  }

  @override
  Future<Membership?> getMembership(
      String membershipId,
      ) {
    return _dataSource.getMembership(
      membershipId,
    );
  }

  @override
  Future<Membership?> getActiveMembership(
      String userId,
      ) {
    return _dataSource.getActiveMembership(
      userId,
    );
  }
}