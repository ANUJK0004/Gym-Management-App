import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

class ProgressRepositoryImpl
    implements ProgressRepository {
  ProgressRepositoryImpl(
      this._dataSource,
      );

  final ProgressRemoteDataSource
  _dataSource;

  @override
  Future<Progress> getProgress(
      String userId,
      ) {
    return _dataSource.getProgress(
      userId,
    );
  }
}