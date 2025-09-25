import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebasePage extends StatefulWidget {
  const FirebasePage({super.key});

  @override
  State<FirebasePage> createState() => _FirebasePageState();
}

class _FirebasePageState extends State<FirebasePage> {
  var docCtl = TextEditingController();
  var nameCtl = TextEditingController();
  var messageCtl = TextEditingController();
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('Document'),
          TextField(controller: docCtl),
          const Text('Name'),
          TextField(controller: nameCtl),
          const Text('Message'),
          TextField(controller: messageCtl),
          FilledButton(
            onPressed: () {
              var data = {
                'name': nameCtl.text,
                'message': messageCtl.text,
                'createAt': DateTime.timestamp(),
              };

              db.collection('inbox').doc('Room1234').set(data);
            },
            child: const Text('Add Data'),
          ),
          FilledButton(onPressed: readData, child: const Text('Read Data')),
        ],
      ),
    );
  }

  void readData() async {
    var result = await db.collection('inbox').doc(docCtl.text).get();
    var data = result.data();
    log(data!['message']);
    log((data['createAt'] as Timestamp).millisecondsSinceEpoch.toString());
  }
}
