import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takemynotes/services/cloud/cloud_note.dart';
import 'package:takemynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:takemynotes/services/crud/notes_service.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  void createNewNote({required String userId}) async {
    //a Document reference is like a stream but it's read AND write !
    await notes.add({
      userIdColumn: userId,
      textColumn: '',
    });
  }

  Future<void> updateNote({required String id, required String text}) async {
    try {
      await notes.doc(id).update({textColumn: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String id}) async {
    try {
      await notes.doc(id).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

//store the notes in a Stream
//we extract the stream of data as it is evolving, we wanna see all the changes happening in real time
//for that reason, we need to subscribe to the snapshots(), all those changes happen inside a list of 'querySnapShots'
//Each query snapshot contains a list of documents
//Collection -> snapshots -> documents
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.userId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String userId}) async {
    try {
      return await notes
          .where(userIdColumn, isEqualTo: userId)
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                    documentId: doc.id,
                    userId: doc.data()[userIdColumn],
                    text: doc.data()[textColumn]);
              }));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  //creating a Singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
