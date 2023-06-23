import 'package:takemynotes/services/auth/firebase_auth_provider.dart';

import 'auth_provider.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider authProvider;

  const AuthService(this.authProvider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) {
    return authProvider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    return authProvider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() {
    return authProvider.logOut();
  }

  @override
  Future<void> sendEmailVerification() {
    return authProvider.sendEmailVerification();
  }

  @override
  Future<void> initialize() {
    return authProvider.initialize();
  }
}
