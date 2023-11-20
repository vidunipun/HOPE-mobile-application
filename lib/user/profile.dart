// ignore_for_file: unused_local_variable, duplicate_ignore, use_key_in_widget_constructors

import 'package:auth/services/auth.dart';
import 'package:auth/transaction/add_card.dart';
import 'package:auth/user/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final AuthServices _auth = AuthServices();
    User? currentUser;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the Edit Profile page when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                print("object");
                
              },
              child: const Card(
                margin: EdgeInsets.all(16.0),
                elevation: 0.0,
                child: ListTile(
                  leading: Icon(Icons.edit), // Edit icon
                  title: Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailsPage(),
                  ),
                );
              },
              child: const Card(
                margin: EdgeInsets.all(16.0),
                elevation: 0.0,
                child: ListTile(
                  leading: Icon(Icons.credit_card), // Card icon
                  title: Text(
                    "Add Card Details",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the Edit Profile page when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: const Card(
                margin: EdgeInsets.all(16.0),
                elevation: 0.0,
                child: ListTile(
                  leading: Icon(Icons.logout), // Edit icon
                  title: Text(
                    "Log Out",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
