import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
  });

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }
}