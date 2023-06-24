import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:takemynotes/services/auth/auth_service.dart';
import 'package:takemynotes/services/crud/notes_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../utilities/logout_dialog.dart';

class NoteTakingView extends StatefulWidget {
  const NoteTakingView({super.key});

  @override
  State<NoteTakingView> createState() => _NoteTakingViewState();
}

class _NoteTakingViewState extends State<NoteTakingView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService =
        NotesService(); //this calls the factory declared in notes_service to call the singleton
    _notesService
        .open(); //open the database and create the local cache for our notes
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState
                          .waiting: // we shouldn't hook a 'done' state for a stream
                      return const Text('waiting for all notes');
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
