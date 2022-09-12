import 'package:notes_app/db_helper/db_helper.dart';

class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority, _color;

  Note(this._title, this._date, this._priority, this._color,
      [this._description]);

  Note.withId(this._id, this._title, this._date, this._priority, this._color,
      [this._description]);

  int get id => _id;

  String get title => _title;

  String get description => _description;

  int get priority => _priority;

  int get color => _color;

  String get date => _date;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      _title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 3) {
      _priority = newPriority;
    }
  }

  set color(int newColor) {
    if (newColor >= 0 && newColor <= 9) {
      _color = newColor;
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Convert a Note object into a Map object
  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     // DatabaseHelper.COLUMN_ID: _id,
  //     map[DatabaseHelper.COLUMN_TITLE]: _title,
  //     DatabaseHelper.COLUMN_DATE: _date,
  //     DatabaseHelper.COLUMN_PRIORITRY: _priority,
  //     DatabaseHelper.COLUMN_COLOR: _color,
  //     DatabaseHelper.COLUMN_DESCRIPTION: _description,
  //   };
  //
  //   if (id != null) {
  //     map[DatabaseHelper.COLUMN_ID] = _id;
  //   }
  //
  //   return map;
  // }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map[DatabaseHelper.COLUMN_ID] = _id;
    }
    map[DatabaseHelper.COLUMN_TITLE] = _title;
    map[DatabaseHelper.COLUMN_DESCRIPTION] = _description;
    map[DatabaseHelper.COLUMN_PRIORITRY] = _priority;
    map[DatabaseHelper.COLUMN_COLOR] = _color;
    map[DatabaseHelper.COLUMN_DATE] = _date;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    _id = map[DatabaseHelper.COLUMN_ID];
    _title = map[DatabaseHelper.COLUMN_TITLE];
    _priority = map[DatabaseHelper.COLUMN_PRIORITRY];
    _color = map[DatabaseHelper.COLUMN_COLOR];
    _date = map[DatabaseHelper.COLUMN_DATE];
    _description = map[DatabaseHelper.COLUMN_DESCRIPTION];
  }
}

final String editText='Edit Note';
final String saveText='Add Note';