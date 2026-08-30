import '../../domain/entities/trainer_profile.dart';
import '../../domain/repositories/trainer_profile_repository.dart';
import '../datasources/trainer_profile_remote_datasource.dart';
import '../models/trainer_profile_model.dart';

class TrainerProfileRepositoryImpl implements TrainerProfileRepository {
  TrainerProfileRepositoryImpl(this._remoteDataSource);

  final TrainerProfileRemoteDataSource _remoteDataSource;

  @override
  Stream<TrainerProfile> watchProfile({String? trainerId}) {
    return _remoteDataSource.watchProfile(trainerId: trainerId);
  }

  @override
  Future<TrainerProfile> getProfile({String? trainerId}) {
    return _remoteDataSource.getProfile(trainerId: trainerId);
  }

  @override
  Future<TrainerProfile> updateProfile(TrainerProfile profile) {
    final model = profile is TrainerProfileModel
        ? profile
        : TrainerProfileModel(
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

  @override
  Future<void> updateAvailability({
    required String trainerId,
    required TrainerAvailability availability,
  }) {
    return _remoteDataSource.updateAvailability(
      trainerId: trainerId,
      availability: availability,
    );
  }

  @override
  Future<void> updateAccountSettings({
    required String trainerId,
    required TrainerAccountSettings settings,
  }) {
    return _remoteDataSource.updateAccountSettings(
      trainerId: trainerId,
      settings: settings,
    );
  }
}
