import '../entities/progress.dart';

abstract class ProgressRepository {
  Future<Progress> getProgress(
      String userId,
      );

  Future<void> updateBodyMetrics({
    required String userId,
    double? weight,
    double? bodyFat,
    double? muscleMass,
  });
}