import 'package:flutter/material.dart';
import 'firestore_service.dart';

class FirestoreTestScreen extends StatelessWidget {
  const FirestoreTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the Firestore service to add data
            firestoreService.addUser('John Doe', 'johndoe@example.com');
          },
          child: const Text('Add Data to Firestore'),
        ),
      ),
    );
  }
}
