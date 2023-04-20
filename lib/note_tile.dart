import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/notes.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'new_note.dart';

class NoteTile extends StatelessWidget {

  final Notes notes;
  const NoteTile({super.key, required this.notes});

  String decodedNote(String note){
    final List noteMap = jsonDecode(note);
    final values = quill.Document.fromJson(noteMap);
    return values.toPlainText();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.black26,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
        child: Column(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  notes.title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                    decodedNote(notes.note).length > 300 ? '${decodedNote(notes.note).substring(0,300)}...' : decodedNote(notes.note),
                    style: const TextStyle( fontFamily: 'GoogleSans', color: Colors.black54)
                ),
              ),
              onTap: () async {
                await Navigator.push( context,
                    MaterialPageRoute(builder: (context) =>  NewNote(notes.id, notes.title, notes.label, notes.createdAt, notes.updatedAt, notes.note, true))
                );
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 14.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LabelWidget(notes: notes),
              ),
            )
          ],
        ),
      )
    );
  }
}

class LabelWidget extends StatelessWidget {
  const LabelWidget({
    super.key,
    required this.notes,
  });

  final Notes notes;

  @override
  Widget build(BuildContext context) {

    if (notes.label == 'Uncategorized') {
      return Container(); // Return an empty container
    }

    return Container(
      decoration:  const BoxDecoration(
        color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child:  Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
        child:  Text(
          notes.label,
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
