import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/notes.dart';
import 'note_tile.dart';

class NotesList extends StatefulWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  @override
  Widget build(BuildContext context) {

    final notes = Provider.of<List<Notes>>(context);

    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index){
          return NoteTile(notes: notes[index]);
        }
    );
  }
}
