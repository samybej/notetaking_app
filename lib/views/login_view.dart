import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takemynotes/services/auth/auth_exceptions.dart';
import 'package:takemynotes/services/auth/bloc/auth_bloc.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/auth/bloc/auth_state.dart';
import 'package:takemynotes/utilities/dialogs/loading_dialog.dart';

import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException ||
              state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(hintText: 'Enter your email'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration:
                  const InputDecoration(hintText: 'Enter your password'),
            ),
            TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;

                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                  /*await AuthService.firebase()
                                  .logIn(email: email, password: password);
            
                              final currentUser = AuthService.firebase().currentUser;
                              if (context.mounted) {
                                if (currentUser?.isEmailVerified ?? false) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      notesRoute, (route) => false);
                                      
                                } else {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      verifyRoute, (route) => false);
                                }
                              }
                              */
                  //Since we are using BlocListener to handle exceptions we can remove the exception handlers from the button.
                  /* } on UserNotFoundAuthException {
                      await showErrorDialog(context, 'User not found');
                    } on WrongPasswordAuthException {
                      await showErrorDialog(context, 'Wrong password');
                    } on GenericAuthException {
                      await showErrorDialog(context, 'Authentification Error');
                    } */
                },

                /*  } on FirebaseAuthException catch (e) {
                            
                              if (e.code == 'user-not-found') {
                                await showErrorDialog(context, 'User not found');
                              } else if (e.code == 'wrong-password') {
                                if (context.mounted) {
                                  await showErrorDialog(context, 'Wrong password');
                                }
                              } else {
                                await showErrorDialog(context, 'Error ${e.code}');
                              }
                            } catch (e) {
                              await showErrorDialog(context, 'Error ${e.toString()}');
                            }
                          }*/

                child: const Text('Login')),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Not registered? Register Here !'))
          ],
        ),
      ),
    );
  }
}
