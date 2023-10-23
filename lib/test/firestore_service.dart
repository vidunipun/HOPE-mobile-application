// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String name, String email) async {
    try {
      await usersCollection.add({
        'name': name,
        'email': email,
      });
      print('Data added to Firestore successfully.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
}
