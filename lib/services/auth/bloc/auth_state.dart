import 'package:flutter/foundation.dart';
import 'package:takemynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

//we can use this state when we are opening the application and waiting for it to load
//we can also use it when we press the 'login' button and wait for the authentication to finish
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

//we can use this state to fetch the 'CurrentUser'
class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  const AuthStateLoggedIn(this.authUser);
}

//failure state (exception)
class AuthStateLoginFailure extends AuthState {
  final Exception exception;

  const AuthStateLoginFailure(this.exception);
}

class AuthStateNotVerified extends AuthState {
  const AuthStateNotVerified();
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

//failure state (exception)
class AuthStateLogoutFailure extends AuthState {
  final Exception exception;

  const AuthStateLogoutFailure(this.exception);
}
