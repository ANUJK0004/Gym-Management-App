import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  ProfileSetupState build() {
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
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
      ProfileSetupNotifier.new,
    );
