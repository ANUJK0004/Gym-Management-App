import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  AuthUser? get currentUser;

  Future<AuthUser> signUp({
    required String email,
    required String password,
  });

  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> sendEmailVerification();
}