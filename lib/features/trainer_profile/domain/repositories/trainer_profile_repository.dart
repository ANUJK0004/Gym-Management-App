import '../entities/trainer_profile.dart';

abstract class TrainerProfileRepository {
  Future<TrainerProfile> getProfile({required String trainerId});
  Future<TrainerProfile> updateProfile(TrainerProfile profile);
}
