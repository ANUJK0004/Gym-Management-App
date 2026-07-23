import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/profile/domain/entities/user_profile.dart';
import 'package:sweatsync/features/profile/domain/repositories/user_profile_repository.dart';

class ProfileSetupState {
  const ProfileSetupState({
    this.displayName = '',
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.activityLevel,
  });

  final String displayName;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? fitnessGoal;
  final String? activityLevel;

  ProfileSetupState copyWith({
    String? displayName,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
  }) {
    return ProfileSetupState(
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  late final UserProfileRepository _repository;

  @override
  ProfileSetupState build() {
    _repository = ref.watch(
          userProfileRepositoryProvider,
        );

    return const ProfileSetupState();
  }

  void setDisplayName(String value) {
    state = state.copyWith(displayName: value);
  }

  void setDateOfBirth(DateTime value) {
    state = state.copyWith(dateOfBirth: value);
  }

  void setGender(String value) {
    state = state.copyWith(gender: value);
  }

  void setHeight(double value) {
    state = state.copyWith(height: value);
  }

  void setWeight(double value) {
    state = state.copyWith(weight: value);
  }

  void setFitnessGoal(String value) {
    state = state.copyWith(fitnessGoal: value);
  }

  void setActivityLevel(String value) {
    state = state.copyWith(activityLevel: value);
  }

  bool validateProfile() {
    return state.displayName
        .trim()
        .isNotEmpty &&
        state.dateOfBirth != null &&
        state.gender != null &&
        state.height != null &&
        state.weight != null &&
        state.fitnessGoal != null &&
        state.activityLevel != null;
  }

  Future<void> completeProfile({
    required String uid,
    required String email,
  }) async {
    if (!validateProfile()) {
      throw Exception(
        'Please complete all profile details.',
      );
    }

    final profile = UserProfile(
      uid: uid,
      email: email,
      displayName: state.displayName.trim(),
      dateOfBirth: state.dateOfBirth,
      gender: state.gender,
      height: state.height,
      weight: state.weight,
      fitnessGoal: state.fitnessGoal,
      activityLevel: state.activityLevel,
      profileCompleted: true,
    );

    await _repository.updateUserProfile(
      profile,
    );
  }


}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
      ProfileSetupNotifier.new,
    );
