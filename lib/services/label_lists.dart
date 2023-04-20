import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class LabelList extends StatefulWidget {
  //const LabelList({Key? key}) : super(key: key);

  @override
  State<LabelList> createState() => _LabelListState();
}

class _LabelListState extends State<LabelList> {

  late FocusNode myFocusNode;
  List<dynamic> _labels = [];
  List<bool> _isChecked = [];

  void _getLabels() async {
    final labelsSnapshot = await FirebaseFirestore.instance.collection('notebook_labels').get();
    setState(() {
      _labels = labelsSnapshot.docs.map((doc) => doc.get('label')).toList();
      _isChecked = List.generate(_labels.length, (index) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    _getLabels();
    myFocusNode = FocusNode();
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
        title: TextField(
          focusNode: myFocusNode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter label name',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
            itemCount: _labels.length,
            itemBuilder: (context, index) {

              return ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(
                    _labels[index],
                ),
                trailing: Checkbox(
                  value: _isChecked[index],
                  onChanged: (value) async {
                    setState(() {
                      _isChecked[index] = value!;
                    });
                  },
                ),
              );
            },
          ),
    );
  }
}
