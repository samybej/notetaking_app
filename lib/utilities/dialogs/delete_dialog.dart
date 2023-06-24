import 'package:flutter/material.dart';
import 'package:takemynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: 'Delete Note ',
          content: 'Are you sure you want to delete this note ?',
          dialogOptionBuilder: () => {'Yes': true, 'Cancel': false})
      .then((value) => value ?? false); // if the value is null return false
}
