import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:zen_notes/services/label_lists.dart';
import 'services/database.dart';

class NewNote extends StatefulWidget {

  late final String id;
  late final String title;
  late final String note;
  late final String label;
  late final Timestamp createdAt;
  late final Timestamp updatedAt;
  bool isReadOnly;

  late String assignedID;

  NewNote(this.id,  this.title, this.label, this.createdAt, this.updatedAt, [this.note = '[{"insert":"\\n"}]', this.isReadOnly = true]);


  @override
  State<NewNote> createState() => _NewNoteState();

}

class _NewNoteState extends State<NewNote> {

  late TextEditingController titleController;
  late flutter_quill.QuillController quillController;
  late FocusNode myFocusNode;
  IconData _icon = Icons.edit;

  @override
  void initState() {
    super.initState();
    widget.assignedID = widget.id;

    myFocusNode = FocusNode();
    titleController = TextEditingController(text: widget.title);
    quillController = flutter_quill.QuillController(
        document: flutter_quill.Document.fromJson(jsonDecode(widget.note)),
        selection: const TextSelection.collapsed(offset: 0)
    );
    myFocusNode.requestFocus();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                //const LabelList();
                await Navigator.push( context,  MaterialPageRoute(builder: (context) =>  LabelList()) );
              },
              icon: const Icon(Icons.label_outline)),
          IconButton(
            icon:  const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: () {
              saveNotes();
              //Show information of Saved!
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved!'),
                  duration: Duration(seconds: 2),
                ),
              );

            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final isDeleted = await delete(widget.id);
              if (isDeleted) {
                if (context.mounted) {
                  Navigator.pop(context, true);
                  //Show information of Deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(_icon),
            onPressed: () {
              setState(() {
                _icon = _icon == Icons.visibility ? Icons.edit : Icons.visibility;
                widget.isReadOnly = !widget.isReadOnly;
              });
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
        child: Column(
          children: [
             TextField(
               controller: titleController,
               enabled: !widget.isReadOnly,
               focusNode: myFocusNode,
               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
               keyboardType: TextInputType.multiline,
               maxLines: null,
               decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
            Expanded(
              child: flutter_quill.QuillEditor.basic(
                controller: quillController,
                readOnly: widget.isReadOnly,
                // true for view only mode
              ),
            ),
            Builder(
              builder: (context) {
                return Visibility(
                  visible: !widget.isReadOnly,
                    child: flutter_quill.QuillToolbar.basic(controller: quillController)
                );
              }
            ),
          ],
        ),
      )
    );
  }

  //Function : Delete
  Future<bool> delete(String id) async {
    final completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                DatabaseService().deleteNotes(widget.id);
                Navigator.of(context).pop();
                completer.complete(true);
              },
            ),
          ],
        );
      },
    );
    return await completer.future;
  }

  //Function : Save Or Add
  Future<void> saveNotes() async {

    var notes = jsonEncode(quillController.document.toDelta().toJson());
    var createdAt = Timestamp.now();
    var updatedAt = Timestamp.now();

    if (widget.assignedID.isEmpty){
      final docID = await DatabaseService().addNotes(titleController.text, notes, widget.label, createdAt, updatedAt);
      setState(() {
        widget.assignedID = docID;
      });
    } else {
      await DatabaseService().updateNotes(widget.assignedID, titleController.text, notes, widget.label, Timestamp.now());
    }
  }

}
