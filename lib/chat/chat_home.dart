import 'package:auth/chat/chat_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: _buildUserList(),
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
        title: Text(data['email']?.toString() ??
            ''), // Wrap the String in a Text widget
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
                  recieverUserID: data['uid']
                  //data['uid']?.toString() ?? widget.recieverUserID,
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
