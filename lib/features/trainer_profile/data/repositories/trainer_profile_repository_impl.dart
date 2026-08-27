import '../../domain/entities/trainer_profile.dart';
import '../../domain/repositories/trainer_profile_repository.dart';
import '../datasources/trainer_profile_remote_datasource.dart';
import '../models/trainer_profile_model.dart';

class TrainerProfileRepositoryImpl implements TrainerProfileRepository {
  TrainerProfileRepositoryImpl(this._remoteDataSource);

  final TrainerProfileRemoteDataSource _remoteDataSource;

  @override
  Future<TrainerProfile> getProfile({required String trainerId}) {
    return _remoteDataSource.getProfile(trainerId: trainerId);
  }

  @override
  Future<TrainerProfile> updateProfile(TrainerProfile profile) {
    final model = TrainerProfileModel(
      id: profile.id,
      name: profile.name,
      title: profile.title,
      email: profile.email,
      initials: profile.initials,
      photoUrl: profile.photoUrl,
      isVerified: profile.isVerified,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      clientCount: profile.clientCount,
      experienceYears: profile.experienceYears,
      sessionCount: profile.sessionCount,
      specializations: profile.specializations,
      certifications: profile.certifications,
      monthlyMetrics: profile.monthlyMetrics,
      availability: profile.availability,
      accountSettings: profile.accountSettings,
    );
    return _remoteDataSource.updateProfile(model);
  }
}
