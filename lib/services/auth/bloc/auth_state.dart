import 'package:flutter/foundation.dart';
import 'package:takemynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({required this.isLoading, this.loadingText = 'Please wait'});
}

class AuthStateOnInitialized extends AuthState {
  const AuthStateOnInitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

//we can use this state to fetch the 'CurrentUser'
class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  const AuthStateLoggedIn({required this.authUser, required bool isLoading})
      : super(isLoading: isLoading);
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
  const AuthStateNotVerified({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut(
      {required this.exception, required bool isLoading, String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({required this.exception, required bool isLoading})
      : super(isLoading: isLoading);
}
