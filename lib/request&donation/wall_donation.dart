// ignore_for_file: avoid_print

import 'dart:async';

import 'package:auth/components/like_button.dart';
import 'package:auth/transaction/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WallDonation extends StatefulWidget {
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

  const WallDonation({
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
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WallDonationState createState() => _WallDonationState();
}

class _WallDonationState extends State<WallDonation> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isliked = false;
  late DocumentReference postRef;
  String? username;
  int likeCount = 0;
  late StreamSubscription<DocumentSnapshot> likeSnapshotSubscription;
  late StreamSubscription<QuerySnapshot> querySnapshotSubscription;
  int? toNow;

  @override
  void initState() {
    super.initState();
    // Get to_now
    FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.postid) // Assuming postid uniquely identifies the post
        .get()
        .then((postSnapshot) {
      if (postSnapshot.exists) {
        setState(() {
          toNow = postSnapshot.data()?['to_now'];
        });
      }
    });

    postRef =
        FirebaseFirestore.instance.collection('donations').doc(widget.uid);

    likeSnapshotSubscription = FirebaseFirestore.instance
        .collection('likes')
        .doc(widget.postid)
        .collection('user_likes')
        .doc(currentUser.uid)
        .snapshots()
        .listen((likeSnapshot) {
      if (likeSnapshot.exists) {
        setState(() {
          isliked = true;
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

  @override
  void dispose() {
    likeSnapshotSubscription.cancel();
    querySnapshotSubscription.cancel();

    super.dispose();
  }

  void toggleLike() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 186, 220, 238),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.firstName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            "Caption : ${widget.caption}",
            style: const TextStyle(fontSize: 16.0),
          ),
          Text(
            "Description : ${widget.description}",
            style: const TextStyle(fontSize: 16.0),
          ),
          Visibility(
            visible: widget.amount != null,
            child: Text(
              "Amount : ${widget.amount}",
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Text(
            "Location : ${widget.location}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          if (widget.imageUrls.isNotEmpty)
            Center(
              child: Column(
                children: widget.imageUrls
                    .map(
                      (imageUrl) => SizedBox(
                        height: 200, // Set the desired height
                        width: 200, // Set the desired width
                        child: Image.network(
                          imageUrl,
                          height: 200, // Set the same height here
                          width: 200, // Set the same width here
                          fit:
                              BoxFit.cover, // Adjust the fit property as needed
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16.0),
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
                      final DocumentSnapshot<Map<String, dynamic>>
                          documentSnapshot = await FirebaseFirestore.instance
                              .collection('bank')
                              .doc(widget.uid)
                              .get();
                      print(widget.uid);

                      if (documentSnapshot.exists) {
                        final String cardNo =
                            documentSnapshot.data()?['card_number'] ?? '';

                        if (cardNo.isNotEmpty) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => payment(
                                postid: widget.postid,
                                cardNo: cardNo,
                                uid: widget.uid,
                              ), // Pass cardNo to Payment
                            ),
                          );
                        } else {
                          // Handle the case when card_no is empty
                          print('Card number is empty.');
                        }
                      } else {
                        // Handle the case when the document does not exist
                        print('Card document not found.');
                      }
                    } catch (e) {
                      print('Error retrieving card details: $e');
                    }
                  },
                  child: const Text('Payment'),
                ),
              ),
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
                    minHeight: 15,
                    //borderRadius: const BorderRadius.all(Radius.circular(10)),
                    value: toNow != null && widget.amount != null
                        ? toNow! / double.tryParse(widget.amount!)!
                        : 0.0,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To fill ${widget.amount != null && toNow != null ? (double.tryParse(widget.amount!)! - toNow!).toStringAsFixed(2) : '0.00'}',
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
    );
  }
}
