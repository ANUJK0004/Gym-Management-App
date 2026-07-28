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

  @override
  Future<void> updateBodyMetrics({
    required String userId,
    double? weight,
    double? bodyFat,
    double? muscleMass,
  }) {
    return _dataSource.updateBodyMetrics(
      userId: userId,
      weight: weight,
      bodyFat: bodyFat,
      muscleMass: muscleMass,
    );
  }
}