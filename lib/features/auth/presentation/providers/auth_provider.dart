import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweatsync/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:sweatsync/features/auth/domain/entities/auth_user.dart';
import 'package:sweatsync/features/auth/domain/repositories/auth_repository.dart';
import 'package:sweatsync/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:sweatsync/features/profile/domain/entities/user_profile.dart';
import 'package:sweatsync/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:sweatsync/features/profile/presentation/providers/user_profile_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(firebaseAuthProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return repository.authStateChanges;
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(ref.watch(userProfileDataSourceProvider));
});



// Auth Controller
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;
  late final UserProfileRepository _profileRepository;

  @override
  Future<void> build() async {
    _authRepository = ref.watch(authRepositoryProvider);

    _profileRepository = ref.watch(userProfileRepositoryProvider);
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authUser = await _authRepository.signUp(
        email: email,
        password: password,
      );

      final profile = UserProfile(
        uid: authUser.id,
        email: authUser.email,
        profileCompleted: false,
      );

      await _profileRepository.createUserProfile(profile);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_authRepository.signOut);
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _authRepository.sendPasswordResetEmail(email: email),
    );
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_authRepository.sendEmailVerification);
  }
}
