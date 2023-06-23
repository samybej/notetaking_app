import 'package:flutter/material.dart';
import 'package:takemynotes/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../utilities/logout_dialog.dart';

class NoteTakingView extends StatefulWidget {
  const NoteTakingView({super.key});

  @override
  State<NoteTakingView> createState() => _NoteTakingViewState();
}

class _NoteTakingViewState extends State<NoteTakingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Page'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          )
        ],
      ),
      body: const Text('These are my notes...'),
    );
  }
}
