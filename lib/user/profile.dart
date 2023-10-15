import 'package:auth/transaction/add_card.dart';
import 'package:auth/user/card.dart';
import 'package:auth/user/edit_profile.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the Edit Profile page when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.all(16.0),
                elevation: 4.0,
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
              child: Card(
                margin: EdgeInsets.all(16.0),
                elevation: 4.0,
                child: ListTile(
                  leading: Icon(Icons.credit_card), // Card icon
                  title: Text(
                    "Add Card Details",
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
