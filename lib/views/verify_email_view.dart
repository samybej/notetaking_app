import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takemynotes/constants/routes.dart';
import 'package:takemynotes/services/auth/auth_service.dart';
import 'package:takemynotes/services/auth/bloc/auth_bloc.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text('Please Check your e-mail to verify your account'),
          const Text('Verification email not sent? Click on the button below'),
          TextButton(
              onPressed: () async {
                context
                    .read<AuthBloc>()
                    .add(const AuthEventSendEmailVerification());
              },
              child: const Text('Send email verification again')),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text('Restart')),
        ],
      ),
    );
  }
}
