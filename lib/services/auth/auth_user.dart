import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable //this class and all its subclasses are immutable = only constant attributes
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(
      {required this.isEmailVerified}); //required means we have to specify the attribute name when constructing an instance.

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(isEmailVerified: user.emailVerified);
}
