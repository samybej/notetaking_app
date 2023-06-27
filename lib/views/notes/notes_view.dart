import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takemynotes/services/auth/auth_service.dart';
import 'package:takemynotes/services/auth/bloc/auth_event.dart';
import 'package:takemynotes/services/cloud/cloud_note.dart';
import 'package:takemynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:takemynotes/views/notes/notes_list_view.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NoteTakingView extends StatefulWidget {
  const NoteTakingView({super.key});

  @override
  State<NoteTakingView> createState() => _NoteTakingViewState();
}

class _NoteTakingViewState extends State<NoteTakingView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService =
        FirebaseCloudStorage(); //this calls the factory declared in notes_service to call the singleton

    super.initState();
  }

  @override
  void dispose() {
    //_notesService.close();
    // we shouldn't close the db otherwise after each hot reload it gets closed
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
              Navigator.of(context).pushNamed(createUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);

                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogout());

                    /* await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                    */
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
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState
                  .waiting: // we shouldn't hook a 'done' state for a stream
            case ConnectionState
                  .active: // we shouldn't hook a 'done' state for a stream
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(id: note.documentId);
                  },
                  onTapNote: (note) {
                    Navigator.of(context)
                        .pushNamed(createUpdateNoteRoute, arguments: note);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
