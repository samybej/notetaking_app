import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); //basically return the value false
              },
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // pop the dialog and return true
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  ).then((value) =>
      value ??
      false); // in case showDialog<bool> returns a null value we return false! we also could change the type of the method to Future<bool?>
}
