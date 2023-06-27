import 'package:flutter/foundation.dart';
import 'package:takemynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateOnInitialized extends AuthState {
  const AuthStateOnInitialized();
}

//we can use this state to fetch the 'CurrentUser'
class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  const AuthStateLoggedIn(this.authUser);
}

//failure state (exception)
//this state is not necessary
//In case the login fails -> we are STILL in the state of Logout !
/*class AuthStateLoginFailure extends AuthState {
  final Exception exception;

  const AuthStateLoginFailure(this.exception);
}
*/

class AuthStateNotVerified extends AuthState {
  const AuthStateNotVerified();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering(this.exception);
}
