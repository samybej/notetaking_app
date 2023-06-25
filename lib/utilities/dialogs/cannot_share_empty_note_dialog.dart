import 'package:flutter/material.dart';
import 'package:takemynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Sharing Note',
      content: 'You cannot share an empty note !',
      dialogOptionBuilder: () => {'Ok': null});
}
