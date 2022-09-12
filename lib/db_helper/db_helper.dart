
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

import '../modal_class/notes.dart';

class DatabaseHelper {
  static DatabaseHelper _instance;

  static Database _database;
  static const _databaseName = "note_db";
  static const _databaseVersion = 3;
  static const _NoteTable = "NOTE";
  static const String COLUMN_ID = "id";
  static const String COLUMN_TITLE = "title";
  static const String COLUMN_DESCRIPTION= "description";
  static const String COLUMN_DATE = "date";
  static const String COLUMN_COLOR = "color";
  static const String COLUMN_PRIORITRY = "priority";
//
  static Database _db;

  DatabaseHelper(Database db) {
    _database = db;
  }

  static Future<DatabaseHelper> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseHelper(await open_or_create_database());
    }

    return Future.value(_instance);
  }

  static Future<Database> open_or_create_database() async {
    // open Database
    var path = join(await getDatabasesPath(), _databaseName);
    var database = await openDatabase(path, version: _databaseVersion,
        onCreate: (db, version) {
      db.execute(
          "CREATE TABLE $_NoteTable ("
              "${COLUMN_ID} INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL ,"
              " ${COLUMN_TITLE} TEXT,"
              "${COLUMN_DATE} TEXT,"
              "${COLUMN_PRIORITRY} INTEGER,"
              "${COLUMN_COLOR} INTEGER,"
              "${COLUMN_DESCRIPTION} TEXT)");

    }, onUpgrade: (db, oldVersion, newVersion) {});

    return Future.value(database);
  }

  Future<int>  updateNote(Note note) async {
    var result = await _database?.update(_NoteTable, note.toMap(),
        where: "id = ? ", whereArgs: [note.id]);
    return result;

  }

  void deleteNote(Note note) async {
    await _database?.delete(_NoteTable, where: "id = ?", whereArgs: [note.id]);
  }



  Future<int> addNote(Note note) async {
    // var values = {COLUMN_TITLE: note.title, COLUMN_DATE: note.date,COLUMN_PRIORITRY:note.priority
    //   ,COLUMN_COLOR:note.color,COLUMN_DESCRIPTION:note.description};
    var result = await _database?.insert(_NoteTable,note.toMap(),nullColumnHack: COLUMN_ID);
    return result;
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    var result = await _database.query(_NoteTable, orderBy: '$COLUMN_PRIORITRY ASC');
    return result;
  }

  Future<List<Note>> getAllnotes() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMap(noteMapList[i]));
    }
    // print('noteList noteList ${noteList}');
    return noteList;
  }
  Future<List<Note>> searchNotes(userinput) async {
    var noteMapList = await _database.rawQuery(" select * from $_NoteTable where $COLUMN_TITLE like '%${userinput}%' or $COLUMN_DESCRIPTION like '%${userinput}%'");
    int count = noteMapList.length;
    List<Note> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMap(noteMapList[i]));
      // print('noteList noteList title  ${noteList[i].title} , description: ${noteList[i].description}, color: ${noteList[i].color}');

    }
    return noteList;
  }

  Future<int> getCount() async {
    // Database db = await this.databse;
    List<Map<String, dynamic>> x = await _database.rawQuery(
        "SELECT COUNT (*) from $_NoteTable");
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> deleteNotes() async {
    int res = await _database.delete(_NoteTable);
    return res;
  }




  void close() {
    _database?.close();
  }
}
