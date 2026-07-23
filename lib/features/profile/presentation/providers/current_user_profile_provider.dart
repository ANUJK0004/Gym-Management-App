import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/profile/domain/entities/user_profile.dart';

final currentUserProfileProvider =
FutureProvider<UserProfile?>((ref) async {
  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    return null;
  }

  final repository =
  ref.watch(
    userProfileRepositoryProvider,
  );

  return repository.getUserProfile(
    authUser.id,
  );
});