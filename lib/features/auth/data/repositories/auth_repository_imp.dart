import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map(
          (user) {
        if (user == null) {
          return null;
        }

        return AuthUserModel.fromFirebaseUser(user);
      },
    );
  }

  @override
  AuthUser? get currentUser {
    final user = _remoteDataSource.currentUser;

    if (user == null) {
      return null;
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.signUp(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'signup-failed',
        message: 'Unable to create user account.',
      );
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'signin-failed',
        message: 'Unable to sign in.',
      );
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _remoteDataSource.sendPasswordResetEmail(
      email: email,
    );
  }

  @override
  Future<void> sendEmailVerification() {
    return _remoteDataSource.sendEmailVerification();
  }
}