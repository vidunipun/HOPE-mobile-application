// ignore_for_file: unused_field, avoid_print

import 'package:auth/constants/colors.dart';
import 'package:auth/events/event_post.dart';
import 'package:auth/events/search_events.dart';
import 'package:auth/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_event.dart';


class EventHome extends StatefulWidget {
  // Renamed Home to EventHome
  const EventHome({Key? key}) : super(key: key);

  @override
  State<EventHome> createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
 
  // Renamed _HomeState to _EventHomeState
  final AuthServices _auth = AuthServices();
  final currentUser = FirebaseAuth.instance.currentUser;
  final textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: startBackgroundBlack,
      appBar: AppBar(
        backgroundColor: startBackgroundBlack,
        title: const Text("Events"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Add your logic for the add icon here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEventsPage(),
                    ),
                  );
                  print('Add icon pressed!');
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.add,
                    color: startButtonGreen,
                    size: 30.0,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  // Add your logic for the search icon here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchEventsPage(),
                    ),
                  );
                  print('Search icon pressed!');
                },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.search,
                    color: startButtonGreen,
                    size: 36.0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Events")
                  .orderBy("TimeStamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: false,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];

                      // Check if the 'Likes' field exists in the document data
                      List<String> likes = post.data().containsKey('Likes')
                          ? List<String>.from(post.data()['Likes'])
                          : [];

                      return EventWallPost(
                        // Updated to EventWallPost
                        caption: post.data()['caption'],
                        user: post.data()['UserEmail'],
                        postid: post.id,
                        description: post.data()['description'],
                        location: post.data()['location'],
                        firstName: post.data()['firstName'],
                        likes: likes,
                        imageUrls: (post.data()['selectedImagesUrls']
                                    as List<dynamic>?)
                                ?.map((dynamic url) => url.toString())
                                .toList() ??
                            [],
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
         
        ],
      ),

    );
  }
}