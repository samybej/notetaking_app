import 'package:flutter/material.dart';
import 'package:takemynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showResetPasswordDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Password Resetting',
      content: 'Check your email to reset your password',
      dialogOptionBuilder: () => {'Ok': null});
}
