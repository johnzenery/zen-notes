import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'models/notes.dart';
import 'notes_list.dart';
import 'services/database.dart';
import 'sidebar.dart';
import 'new_note.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Zen Notes',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black54),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Zen Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState();

  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<Notes>?>.value(
      value: DatabaseService().getNotes,
      initialData: const [],
      child: Scaffold(

        drawer: const SideBar(),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children:  [
               const Expanded(child:
                Text(
                  'Search your notes',
                  style: TextStyle(
                      fontSize: 16,
                  ),
                )
              ),
              IconButton(
                  onPressed: (){}, icon: const Icon(Icons.person)
              )
            ],
          ),
          elevation: 0,
        ),

        body: const NotesList(),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push( context,
                MaterialPageRoute(builder: (context) =>  NewNote('','','Uncategorized', Timestamp.now(), Timestamp.now(), '[{"insert":"\\n"}]', false))
              );
          },
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class NotesCard extends StatelessWidget {
  final Notes notes;

  const NotesCard({super.key, required this.notes});

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
      child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 25.0, top: 15.0),
            child: Text(
              notes.title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
                decodedNote(notes.note).length > 300 ? '${decodedNote(notes.note).substring(0,300)}...' : decodedNote(notes.note),
                style: const TextStyle( fontFamily: 'GoogleSans', color: Colors.black54)
            ),
          ),
          trailing: notes.label != 'Uncategorized' ? Container(
            decoration:  BoxDecoration(
                border: Border.all(
                    color: Colors.black45, width: .5
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            child:  Padding(
              padding: const EdgeInsets.all(3.0),
              child:  Text(
                notes.label,
                style: const TextStyle(
                  fontFamily: 'GoogleSans',
                  color: Colors.black45,
                  fontSize: 12,
              ),
            ),
          ),
            ) : null,
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  NewNote(notes.id, notes.title, notes.label, notes.createdAt, notes.updatedAt, notes.note))
            );
          },
        ),
      );
  }

}
