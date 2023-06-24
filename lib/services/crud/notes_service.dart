import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

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

class NotesService {
  Database? _db;

  Future<DatabaseUser> createUser({required String email}) async {
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

  Future<DatabaseUser> getUser({required String email}) async {
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
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser user}) async {
    final db = _getDatabaseOrThrow();
    final result = await getUser(email: user.email);

    if (result != user) {
      throw CouldNotFindUser();
    } else {
      const text = '';
      final noteId =
          await db.insert(noteTable, {userIdColumn: user.id, textColumn: text});

      return DatabaseNote(id: noteId, userId: user.id, text: text);
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final note =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (note.isEmpty) {
      throw NoteNotFound();
    } else {
      return DatabaseNote.fromRow(note.first);
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {textColumn: text});

    if (updatedCount != 1) {
      throw NoteNotUpdated();
    } else {
      return DatabaseNote(id: note.id, userId: note.userId, text: text);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
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
