import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:takemynotes/constants/routes.dart';

import '../utilities/show_error_dialog.dart';

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
    return Scaffold(
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
            decoration: const InputDecoration(hintText: 'Enter your password'),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, password: password);

                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (context.mounted) {
                    if (currentUser?.emailVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute, (route) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyRoute, (route) => false);
                    }
                  }
                } on FirebaseAuthException catch (e) {
                  devtools.log("an error occured when logging in.");
                  devtools.log(e.runtimeType
                      .toString()); //type of exception , this allows us to chose the correct exception type on the catch clause above
                  //In our case, the exception was of type FirebaseAuthException!
                  devtools.log(e.toString());
                  devtools.log(e.code); //reason for exception
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
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered? Register Here !'))
        ],
      ),
    );
  }
}
