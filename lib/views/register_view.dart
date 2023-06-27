import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takemynotes/constants/routes.dart';
import 'package:takemynotes/services/auth/auth_exceptions.dart';
import 'package:takemynotes/services/auth/auth_service.dart';
import 'package:takemynotes/services/auth/bloc/auth_bloc.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/auth/bloc/auth_state.dart';

import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email already in use');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
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

                  context
                      .read<AuthBloc>()
                      .add(AuthEventRegister(email, password));
                  /*try {
                    await AuthService.firebase()
                        .createUser(email: email, password: password);

                    //final user = AuthService.firebase().currentUser;
                    await AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(context, 'Weak Password');
                  } on EmailAlreadyInUseAuthException {
                    await showErrorDialog(context, 'Email is already in use');
                  } on InvalidEmailAuthException {
                    await showErrorDialog(context, 'Invalid email');
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Registration Error');
                  }
                  */
                },
                child: const Text('Register')),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text('Already Registered? Login Here!'))
          ],
        ),
      ),
    );
  }
}
