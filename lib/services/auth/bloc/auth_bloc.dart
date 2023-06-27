import 'package:bloc/bloc.dart';
import 'package:takemynotes/services/auth/auth_provider.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateOnInitialized()) {
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
      },
    );

    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else if (user.isEmailVerified == false) {
          emit(const AuthStateNotVerified());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;

        try {
          await provider.createUser(email: email, password: password);

          await provider.sendEmailVerification();
          emit(const AuthStateNotVerified());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      },
    );
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));

        final email = event.email;
        final password = event.password;

        try {
          final user = await provider.logIn(email: email, password: password);

          if (user.isEmailVerified == false) {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));

            emit(const AuthStateNotVerified());
          } else {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));

            emit(AuthStateLoggedIn(user));
          }

          //we need to add 'on Exception' because in dart 'e' can be any type
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    on<AuthEventLogout>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );
  }
}
