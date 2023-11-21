// ignore_for_file: avoid_print

import 'package:auth/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a user from UID
  UserModel? _userWithFirebaseUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Stream to get the currently authenticated user
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaseUserUid);
  }

  // Sign in with anonymous account
  Future signInAnonoymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userWithFirebaseUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Register a user with email, password, and first name and save data to Firestore
  Future registerWithEmailAndPassword(
      String email,
      String fname,
      String lname,
      String mobilenumber,
      String address,
      String password,
      String idnumber,
      int points) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      print('Last Name: $lname');
      print('Email: $email');

      // Save user data to Firestore using UID as document ID
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'firstName': fname, // Add the first name here
        'email': email,
        'lastName': lname,
        'mobileNumber': mobilenumber,
        'address': address,
        'uid': user?.uid,
        'idnumber': idnumber,
        'points': points,
      });

      return _userWithFirebaseUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Sign in using email and password
  Future signInUsingEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userWithFirebaseUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }
}
