// ignore_for_file: avoid_print

import 'package:auth/chat/chat_home.dart';
import 'package:auth/constants/colors.dart';
import 'package:auth/events/events_wall.dart';
import 'package:auth/request&donation/request_donation%5B1%5D.dart';
import 'package:auth/screens/home/wall/wall_post.dart';
import 'package:auth/services/auth.dart';

import 'package:auth/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthServices _auth = AuthServices();
  User? currentUser;

  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    updatemysql();
    print(currentUser!.uid);
  }

  Future<void> updatemysql() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      try {
        DocumentSnapshot userSnapshot = await users.doc(uid).get();
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';
          String email = userData['email'] ?? '';
          String mobileNumber = userData['mobileNumber'] ?? '';
          String address = userData['address'] ?? '';

          try {
            String uri = "http://10.34.26.97/mysqlflutter/insert_record.php";
            var res = await http.post(Uri.parse(uri), body: {
              "fname": firstName,
              "lname": lastName,
              "email": email,
              "uid": uid,
              "mobileNo": mobileNumber,
              "address": address,
            });

            if (res.statusCode == 200) {
              // Successfully inserted data into MySQL
              print("Data inserted into MySQL");
            } else {
              // Handle HTTP error
              print("HTTP Error: ${res.statusCode}");
            }
          } catch (e) {
            // Handle HTTP request exception
            print("HTTP Request Exception: $e");
          }
        }
      } catch (e) {
        // Handle Firestore error
        print("Error fetching user data from Firestore: $e");
      }
    }
  }

  Future<String?> fetchProfilePictureURL(String userId) async {
    String? profilePictureURL = '';
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      profilePictureURL = userData['profilePictureURL'];
    }
    return profilePictureURL;
  }

  Future<String> fetchUserRank(String userId) async {
    String rank = 'No Rank';

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      var data = userSnapshot.data() as Map<String, dynamic>;
      if (data != null && data.containsKey('rank')) {
        rank = data['rank'];
      }
    }

    return rank;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonbackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove the elevation (box around AppBar)
        automaticallyImplyLeading: false, // Remove the back button

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "HOPE",
                style: TextStyle(
                  color: buttonbackground,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("requests")
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

                      // Get the user's profile picture URL
                      return FutureBuilder(
                        future: fetchProfilePictureURL(post.data()['userId']),
                        builder: (context, profilePictureSnapshot) {
                          if (profilePictureSnapshot.connectionState ==
                              ConnectionState.done) {
                            String? profilePictureURL =
                                profilePictureSnapshot.data;

                            return FutureBuilder(
                              future: fetchUserRank(
                                  post.data()['userId']), // Use fetchUserRank
                              builder: (context, rankSnapshot) {
                                if (rankSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  String? rank = rankSnapshot.data;

                                  return WallPost(
                                    caption: post.data()['caption'],
                                    user: post.data()['UserEmail'],
                                    uid: post.data()['userId'],
                                    postid: post.id,
                                    amount: post.data()['amount'],
                                    to_now: post.data()['to_now'],
                                    description: post.data()['description'],
                                    location: post.data()['location'],
                                    firstName: post.data()['firstName'],
                                    likes: likes,
                                    imageUrls:
                                        (post.data()['selectedImagesUrls']
                                                    as List<dynamic>?)
                                                ?.map((dynamic url) =>
                                                    url.toString())
                                                .toList() ??
                                            [],
                                    profilePictureURL: profilePictureURL,
                                    lastName: post.data()['lastName'],
                                    points: post.data()['points'],
                                    rank: rank,
                                    verified: post.data()['verified'],
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: buttonbackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 12), // Adjust the margin
                  child: IconButton(
                    onPressed: () {
                      // Handle Home button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                      );
                      print(currentUser?.uid);
                    },
                    icon: Container(
                      width: 40,
                      height: 40,
                      color: buttonbackground,
                      child: Image.asset("assets/Home.png"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    // Handle Chat button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatHomePage(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    color: buttonbackground,
                    child: Image.asset("assets/Chat Round Dots.png"),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(0),
                  child: IconButton(
                    onPressed: () {
                      // Handle Add post button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectionPage(),
                        ),
                      );
                    },
                    iconSize: 70,
                    icon: CircleAvatar(
                      backgroundColor: const Color(0xFF0BFFFF),
                      radius: 40,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Add Circle.png',
                          width: 43,
                          height: 43,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    // Handle events button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventHome(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    color: buttonbackground,
                    child: Image.asset("assets/Calendar Date.png"),
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    // Handle Profile button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    color: buttonbackground,
                    child: Image.asset("assets/Combined-Shape.png"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
