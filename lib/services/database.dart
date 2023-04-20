import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zen_notes/models/notes.dart';

class DatabaseService{

  //Collection reference
  final CollectionReference noteBookCollection = FirebaseFirestore.instance.collection("notebook");

  Future<String> addNotes(String title, String notes, String label, Timestamp createdAt, Timestamp updatedAt) async {
    DocumentReference document = await noteBookCollection.add({
      'title' : title,
      'notes' : notes,
      'label' : label,
      'createdAt' : createdAt,
      'updatedAt' : updatedAt
    });
    return document.id;
  }

  Future updateNotes(String id, String title, String notes, String label, Timestamp updatedAt) async {
    return await noteBookCollection.doc(id).update({
      'title' : title,
      'notes' : notes,
      'label' : label,
      'updatedAt' : updatedAt
    });
  }

  Future deleteNotes(String id) async {
    return await noteBookCollection.doc(id).delete();
  }

  List<Notes> _notesListFromSnapshot(QuerySnapshot snapshot) {
    final notes = snapshot.docs.map((doc) {
      final id = doc.id;
      final data = doc.data() as Map<String, dynamic>?;
      return Notes(
          id: id,
          title: data?['title'] ?? '',
          note: data?['notes'] ?? '',
          label: data?['label'] ?? '',
          createdAt: data?['createdAt'] ?? Timestamp.now(),
          updatedAt: data?['updatedAt'] ?? Timestamp.now(),
      );
    }).toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Stream<List<Notes>> get getNotes {
    return noteBookCollection.snapshots().map(_notesListFromSnapshot);
  }
}