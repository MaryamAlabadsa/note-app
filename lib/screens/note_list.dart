import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';

import '../db_helper/db_helper.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  List<Note> noteList;

  bool isLoading = false;
  int count = 0;
  int axisCount = 2;
  DatabaseHelper _databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('_databaseHelper1 ${_databaseHelper}');

    DatabaseHelper.getInstance().then((value) => setState(() {
          _databaseHelper = value;
          updateListView();
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
    }
    Widget myAppBar() {
      return AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headline5),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: noteList.isEmpty
            ? Container()
            : IconButton(
                splashRadius: 22,
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () async {
                  final Note result = await showSearch(
                      context: context,
                      delegate: NotesSearch(
                          // notes: noteList, databaseHelper: _databaseHelper));
                          notes: noteList));
                  if (result != null) {
                    navigateToDetail(result, 'Edit Note');
                  }
                },
              ),
        actions: <Widget>[
          noteList.isEmpty
              ? Container()
              : Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      icon: Icon(
                        Icons.restore_from_trash_sharp,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _databaseHelper
                            .deleteNotes()
                            .then((value) => print('value inserted ${value}'));

                        setState(() {});
                      },
                    ),
                    IconButton(
                      splashRadius: 22,
                      icon: Icon(
                        axisCount == 2 ? Icons.list : Icons.grid_on,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          axisCount = axisCount == 2 ? 4 : 2;
                        });
                      },
                    )
                  ],
                )
        ],
      );
    }

    return Scaffold(
      appBar: myAppBar(),
      body: noteList.isEmpty
          ? Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Click on the add button to add a new note!',
                      style: Theme.of(context).textTheme.bodyText2),
                ),
              ),
            )
          : Container(color: Colors.white, child: getNotesList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0), saveText);
        },
        tooltip: 'Add Note',
        shape: const CircleBorder(
            side: BorderSide(color: Colors.black, width: 2.0)),
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget getNotesList() {
    return new FutureBuilder<List<Note>>(
        future: updateListView(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new StaggeredGridView.countBuilder(
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 4,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () {
                  navigateToDetail(snapshot.data[index], editText);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: colors[snapshot.data[index].color],
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot.data[index].title,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ),
                            Text(
                              getPriorityText(snapshot.data[index].priority),
                              style: TextStyle(
                                  color: getPriorityColor(
                                      snapshot.data[index].priority)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                    snapshot.data[index].description ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              )
                            ],
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(snapshot.data[index].date,
                                  style: Theme.of(context).textTheme.subtitle2),
                            ])
                      ],
                    ),
                  ),
                ),
              ),
              staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          return new Container(
            alignment: AlignmentDirectional.center,
            child: new CircularProgressIndicator(),
          );
          ;
        });
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
        break;
      case 2:
        return '!!';
        break;
      case 3:
        return '!';
        break;

      default:
        return '!';
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));
  }

  Future<List<Note>> updateListView() async {
    Future<List<Note>> notes = _databaseHelper.getAllnotes();
    notes.then((value) {
      for (int i = 0; i < value.length; i++) {
        noteList.add(value[i]);
      }
    });
    setState(() {
      notes.then((value) {
        for (int i = 0; i < value.length; i++) {
          noteList.add(value[i]);
        }
      });
    });
    return notes;
  }
}
