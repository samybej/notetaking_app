import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:takemynotes/firebase_options.dart';
import 'package:takemynotes/views/login_view.dart';
import 'package:takemynotes/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            /*  final user = FirebaseAuth.instance.currentUser;
              print(user);
              final emailVerified = user?.emailVerified ?? false;
              if (emailVerified) {
              } else {
                return const VerifyEmailView();
              }
              return const Text('Done');*/
            return const LoginView();
          default:
            return const CircularProgressIndicator(); //if internet connection is slow this is the first thing that appears before the user/email column
        }
      },
    );
  }
}
