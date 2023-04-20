import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {

  late final String id;
  late final String title;
  late final String note;
  late final String label;
  late final Timestamp createdAt;
  late final Timestamp updatedAt;

  Notes({required this.id, required this.title, required this.note, required this.label, required this.createdAt, required this.updatedAt });
}