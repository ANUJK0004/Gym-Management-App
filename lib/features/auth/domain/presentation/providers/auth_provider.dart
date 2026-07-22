import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweatsync/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:sweatsync/features/auth/domain/entities/auth_user.dart';
import 'package:sweatsync/features/auth/domain/repositories/auth_repository.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider =
Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  );
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return repository.authStateChanges;
});


final authControllerProvider =
AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => _repository.signUp(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => _repository.signIn(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.signOut,
    );
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => _repository.sendPasswordResetEmail(
        email: email,
      ),
    );
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.sendEmailVerification,
    );
  }
}