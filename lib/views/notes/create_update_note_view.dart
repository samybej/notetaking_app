import 'package:flutter/material.dart';
import 'package:takemynotes/services/auth/auth_service.dart';
import 'package:takemynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:takemynotes/services/cloud/cloud_note.dart';
import 'package:takemynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;

  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;

    await _notesService.updateNote(id: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener((_textControllerListener));

    _textController.addListener(
        (_textControllerListener)); // by adding the listener the note gets updated automatically as we type
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();

    super.dispose();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;

      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;

    final newNote = await _notesService.createNewNote(userId: currentUser.id);
    _note = newNote;

    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(id: note.documentId);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;

    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
          id: note.documentId, text: _textController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null, //necessary when using "multiline"
                decoration:
                    const InputDecoration(hintText: 'Type your note here '),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
