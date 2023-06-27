import 'package:bloc/bloc.dart';
import 'package:takemynotes/services/auth/auth_provider.dart';
import 'package:takemynotes/services/auth/auth_user.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else if (user.isEmailVerified == false) {
          emit(const AuthStateNotVerified());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );

    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoading());

        final email = event.email;
        final password = event.password;

        try {
          final user = await provider.logIn(email: email, password: password);

          emit(AuthStateLoggedIn(user));
          //we need to add 'on Exception' because in dart 'e' can be any type
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      },
    );

    on<AuthEventLogout>(
      (event, emit) async {
        emit(const AuthStateLoading());

        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut());
        } on Exception catch (e) {
          emit(AuthStateLogoutFailure(e));
        }
      },
    );
  }
}
