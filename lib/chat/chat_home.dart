import 'package:auth/chat/chat_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../screens/home/wall/home.dart';

class ChatHomePage extends StatefulWidget {
  //final String recieverUserEmail;
  //final String recieverUserID;

  const ChatHomePage({
    Key? key,
    //required this.recieverUserID,
    // required this.recieverUserEmail,
  }) : super(key: key);

  //@override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          startBackgroundBlack, // Set your desired background color
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                    );
                  },
                ),
                Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading...');
          }

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Display all users except the current user
    if (_auth.currentUser!.email != data['email']) {
      // print(data['email']);
      //String clickedEmail = data['email']?.toString() ?? '';
      //print(clickedEmail);

      return ListTile(
        title: Text(
          data['firstName']?.toString() ?? '',
          style: TextStyle(
            color: Colors.white,
          ),
        ), // Wrap the String in a Text widget
        onTap: () {
          //print(data['email']);
          //print('acbccc');
          //print(data['uid']?.toString() ?? widget.recieverUserID);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                recieverUserEmail: data['email'],
                //data['email']?.toString() ?? widget.recieverUserEmail,
                recieverUserID: data['uid'],
                //data['uid']?.toString() ?? widget.recieverUserID,
                firstName: data['firstName']?.toString() ?? '',
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}