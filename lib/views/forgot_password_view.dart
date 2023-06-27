import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takemynotes/services/auth/bloc/auth_bloc.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/auth/bloc/auth_state.dart';
import 'package:takemynotes/utilities/dialogs/error_dialog.dart';
import 'package:takemynotes/utilities/dialogs/password_reset_email_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgottenpassword) {
          if (state.hasSentEmail) {
            _textEditingController.clear();
            await showResetPasswordDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(context,
                'An error occured while sending the email. Please make sure that you are a registered user');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Resetting password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  'Please enter your email so that we could send you a password reset link'),
              TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Type your email address here'),
              ),
              TextButton(
                onPressed: () {
                  final email = _textEditingController.text;

                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgottenPassword(email));
                },
                child: const Text('Send Email'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text('login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
