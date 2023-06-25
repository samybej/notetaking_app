import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'package:takemynotes/extensions/list/filter.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes =
      []; //this is our cache where we keep all of our notes (for the current user).

  DatabaseUser? _user;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() =>
      _shared; //these 3 steps help create a singleton for our noteService

  late final StreamController<List<DatabaseNote>>
      _notesStreamController; // the UI is going to interact with this controller

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id; //should be true
        } else {
          throw UserShouldBeLoggedInBeforeViewingNotes();
        }
      });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();

    _notes = allNotes.toList();

    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email.toLowerCase());
  }

  Future<DatabaseUser> getOrCreateUser(
      {required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserNotExists {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDatabaseOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw UserNotExists();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser user}) async {
    await _ensureDatabaseOpen();

    final db = _getDatabaseOrThrow();
    final result = await getUser(email: user.email);

    if (result != user) {
      throw CouldNotFindUser();
    } else {
      const text = '';
      final noteId =
          await db.insert(noteTable, {userIdColumn: user.id, textColumn: text});

      final note = DatabaseNote(id: noteId, userId: user.id, text: text);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final result =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      throw NoteNotFound();
    } else {
      final note = DatabaseNote.fromRow(result.first);
      //Let's update the local cache because we could try to read a note from our cache but it's outdated.
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updatedCount = await db.update(
        noteTable, where: 'id = ?', whereArgs: [note.id], {textColumn: text});

    if (updatedCount == 0) {
      throw NoteNotUpdated();
    } else {
      final updatedNote =
          DatabaseNote(id: note.id, userId: note.userId, text: text);
      _notes.removeWhere((n) => n.id == note.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final nbrDeleted = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return nbrDeleted;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDatabaseOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);

      _db = db;
      //creating the user table
      await db.execute(createUserTable);
      //creating the note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnabletoGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;

  const DatabaseNote(
      {required this.id, required this.userId, required this.text});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  @override
  String toString() {
    return 'Note id : $id , note message : $text';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';

const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
); ''';

const createNoteTable = '''
CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
); ''';
