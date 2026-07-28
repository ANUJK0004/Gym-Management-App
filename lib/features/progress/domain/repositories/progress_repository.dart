import '../entities/progress.dart';

abstract class ProgressRepository {
  Future<Progress> getProgress(
      String userId,
      );
}