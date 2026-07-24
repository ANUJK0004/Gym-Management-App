import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/profile/domain/entities/user_profile.dart';

final currentUserProfileProvider =
FutureProvider<UserProfile?>((ref) async {
  // Wait until Firebase Auth has completely resolved
  // the current authentication state.
  final authUser = await ref.watch(
    authStateProvider.future,
  );

  // No authenticated user.
  if (authUser == null) {
    return null;
  }

  // Get the profile repository.
  final repository = ref.watch(
    userProfileRepositoryProvider,
  );

  // Fetch profile from Firestore.
  return repository.getUserProfile(
    authUser.id,
  );
});