import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable //this class and all its subclasses are immutable = only constant attributes
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  const AuthUser(
      {required this.id,
      required this.email,
      required this.isEmailVerified}); //required means we have to specify the attribute name when constructing an instance.

  factory AuthUser.fromFirebase(User user) => AuthUser(
      id: user.uid, email: user.email!, isEmailVerified: user.emailVerified);
}
