import 'package:auth/components/like_button.dart';
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

  @override
  void initState() {
    super.initState();
    //get to_now
    FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.postid) // Assuming postid uniquely identifies the post
        .get()
        .then((postSnapshot) {
      if (postSnapshot.exists) {
        setState(() {
          toNow = postSnapshot.data()?['to_now'];
        });
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

  @override
  void dispose() {
    likeSnapshotSubscription.cancel();
    querySnapshotSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255,255,255),
        
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
              "amount : ${widget.amount}",
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
                      (imageUrl) => Container(
                        height: screenHeight*0.5, // Set the desired height
                        width: screenWidth, // Set the desired width
                        child: Image.network(
                          imageUrl,
                          height: screenHeight*0.5, // Set the desired height
                          width: screenWidth, // Set the same width here
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
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    LikeButton(isliked: isliked, onTap: toggleLike),
    const SizedBox(width: 8.0),
    const Text(
      'Like',
      style: TextStyle(fontSize: 16.0),
    ),
    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.comment_outlined,
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          const Text(
            'Comment',
            style: TextStyle(fontSize: 16.0),
          ),
          Visibility(
            visible: widget.amount != null && toNow != null,
            child: ElevatedButton(
              onPressed: () async {
                // ... existing code
              },
              child: Text('Payment'),
            ),
          ),
        ],
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    value: toNow != null && widget.amount != null
                        ? toNow! / double.tryParse(widget.amount!)!
                        : 0.0,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To fill ${widget.amount != null && toNow != null ? (double.tryParse(widget.amount!)! - toNow!).toStringAsFixed(2) : '0.00'}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        'Percentage: ${widget.amount != null && toNow != null ? ((toNow! / double.tryParse(widget.amount!)!) * 100).toStringAsFixed(2) : '0.00'}%',
                        style: TextStyle(fontSize: 16.0),
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
