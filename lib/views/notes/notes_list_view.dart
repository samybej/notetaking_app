import 'package:flutter/material.dart';
import 'package:takemynotes/services/cloud/cloud_note.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  //Firebase by default works with iterables and not lists
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;

  const NotesListView(
      {super.key,
      required this.notes,
      required this.onDeleteNote,
      required this.onTapNote});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final currentNote = notes.elementAt(index);
        return ListTile(
          title: Text(
            currentNote.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(currentNote);
              }
            },
            icon: const Icon(Icons.delete),
          ),
          onTap: () {
            onTapNote(currentNote);
          },
        );
      },
    );
  }
}
