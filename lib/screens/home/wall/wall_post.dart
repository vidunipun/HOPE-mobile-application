// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:auth/components/like_button.dart';
import 'package:auth/constants/colors.dart';
import 'package:auth/transaction/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WallPost extends StatefulWidget {
  final String caption;
  final String description;
  final String user;
  final String location;
  final String postid;
  final String firstName;
  final List<String> likes;
  final List<String> imageUrls;
  final String uid;
  final String? amount;
  final String? profilePictureURL;
  final String lastName;
  final String? points;
  final String? rank;
  final bool verified;
  final int? to_now;

  const WallPost({
    Key? key,
    required this.caption,
    required this.user,
    required this.postid,
    required this.description,
    required this.location,
    required this.firstName,
    required this.likes,
    required this.imageUrls,
    required this.uid,
    this.amount,
    this.profilePictureURL,
    required this.lastName,
    required this.points,
    required this.rank,
    required this.verified,
    this.to_now,
  }) : super(key: key);

  @override
  _WallPostState createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isliked = false;
  late DocumentReference postRef;
  String? username;
  int likeCount = 0;
  late StreamSubscription<DocumentSnapshot> likeSnapshotSubscription;
  late StreamSubscription<QuerySnapshot> querySnapshotSubscription;
  int? toNow;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    //get to_now
    FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.postid)
        .get()
        .then((postSnapshot) {
      if (mounted) {
        // Check if the widget is still mounted
        if (postSnapshot.exists) {
          var data = postSnapshot.data();
          if (data != null && data.containsKey('to_now')) {
            setState(() {
              toNow = data['to_now'];
            });
          }
        }
      }
    });

    postRef = FirebaseFirestore.instance.collection('request').doc(widget.uid);

    likeSnapshotSubscription = FirebaseFirestore.instance
        .collection('likes')
        .doc(widget.postid)
        .collection('user_likes')
        .doc(currentUser.uid)
        .snapshots()
        .listen((likeSnapshot) {
      if (likeSnapshot.data() != null) {
        setState(() {
          isliked = true;
        });
      } else {
        setState(() {
          isliked = false;
        });
      }
    });

    querySnapshotSubscription = FirebaseFirestore.instance
        .collection('likes')
        .doc(widget.postid)
        .collection('user_likes')
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        likeCount = querySnapshot.docs.length;
      });
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user)
        .get()
        .then((userSnapshot) {
      if (userSnapshot.exists) {
        setState(() {
          username = userSnapshot.data()?['firstName'];
        });
      }
    });
  }

  void toggleLike() {
    if (mounted) {
      setState(() {
        isliked = !isliked;

        if (isliked) {
          FirebaseFirestore.instance
              .collection('likes')
              .doc(widget.postid)
              .collection('user_likes')
              .doc(currentUser.uid)
              .set({'liked': true});
          likeCount++;
        } else {
          FirebaseFirestore.instance
              .collection('likes')
              .doc(widget.postid)
              .collection('user_likes')
              .doc(currentUser.uid)
              .delete();
          likeCount--;
        }
      });
    }
  }

  //check user have card

  @override
  void dispose() {
    try {
      likeSnapshotSubscription.cancel();
      querySnapshotSubscription.cancel();
    } catch (e) {
      // Handle any exceptions thrown during cancellation
      print('Error during disposal: $e');
    }
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Visibility(
      visible: widget.verified == true,
      child: Visibility(
     visible: widget.amount == null ||
    (widget.to_now != null &&
        (double.tryParse(widget.to_now!.toString()) ?? double.infinity) <
            (double.tryParse(widget.amount!.toString()) ?? double.infinity)),


        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Display the user's profile picture
                  if (widget.profilePictureURL != null &&
                      widget.profilePictureURL!.isNotEmpty)
                    CircleAvatar(
                      radius: 24, //   size
                      backgroundImage: NetworkImage(widget.profilePictureURL!),
                    ),
                  if (widget.profilePictureURL != null &&
                      widget.profilePictureURL!.isNotEmpty)
                    const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.firstName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.lastName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10), // Add  vertical spacing
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          ' ${widget.rank ?? "No Rank"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Builder(
                    builder: (BuildContext context) {
                      print('Rank: ${widget.rank ?? "No Rank"}');
                      return Container(); // Return an empty container to avoid UI issues
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align children to the left
                    children: [
                      Text(
                        " ${widget.caption}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: widget.amount != null,
                        child: Text(
                          "Need Rs ${widget.amount}",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 28, // Set  icon color
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Location:",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.location,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              if (widget.imageUrls.isNotEmpty)
                Center(
                  child: Column(
                    children: widget.imageUrls
                        .map(
                          (imageUrl) => SizedBox(
                            height: screenHeight * 0.5, // Set the  height
                            width: screenWidth, // Set the  width
                            child: Image.network(
                              imageUrl,
                              height: screenHeight * 0.5,
                              width: screenWidth,
                              fit: BoxFit.cover, // Adjust the fit property
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 10.0),
              Text(likeCount.toString()), // Display the like count

              Row(
                children: [
                  LikeButton(isliked: isliked, onTap: toggleLike),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Like',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(width: 100.0),
                  const Icon(
                    Icons.comment_outlined,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Comment',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(
                    width: 17,
                  ),
                  Visibility(
                    visible: widget.amount != null && toNow != null,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Get the current user
                          User? currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser != null) {
                            // Check if the card document exists
                            DocumentSnapshot<Map<String, dynamic>>
                                cardDocumentSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('cards')
                                    .doc(currentUser.uid)
                                    .get();

                            if (cardDocumentSnapshot.exists) {
                              // Card document exists, proceed to payment page
                              final DocumentSnapshot<Map<String, dynamic>>
                                  documentSnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('Bank')
                                      .doc(widget.uid)
                                      .get();

                              if (documentSnapshot.exists) {
                                final String cardNo =
                                    documentSnapshot.data()?['card_number'] ??
                                        '';

                                if (cardNo.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => payment(
                                        postid: widget.postid,
                                        cardNo: cardNo,
                                        uid: widget.uid,
                                      ),
                                    ),
                                  );
                                } else {
                                  // if card_no is empty
                                  print('Card number is empty.');
                                }
                              } else {
                                //if document does not exist
                                print('Card document not found.');
                              }
                            } else {
                              // if card document does not exist
                              print('Card document not found.');
                            }
                          } else {
                            // if there is no current user
                            print('No current user.');
                          }
                        } catch (e) {
                          print('Error retrieving card details: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: buttonbackground, // Set  button color
                      ),
                      child: const Text('Payment'),
                    ),
                  ),

                  // Display images if available
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Visibility(
                  visible: widget.amount != null && toNow != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LinearProgressIndicator(
                        backgroundColor:
                            buttonbackground, // Set the background color
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            startButtonGreen),
                        minHeight: 15,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        value: toNow != null && widget.amount != null
                            ? toNow! / double.tryParse(widget.amount!)!
                            : 0.0,
                      ),
                      const SizedBox(
                        height: 1.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To fill Rs. ${widget.amount != null && toNow != null ? (double.tryParse(widget.amount!)! - toNow!).toStringAsFixed(2) : '0.00'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            'Percentage: ${widget.amount != null && toNow != null ? ((toNow! / double.tryParse(widget.amount!)!) * 100).toStringAsFixed(2) : '0.00'}%',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ],
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
