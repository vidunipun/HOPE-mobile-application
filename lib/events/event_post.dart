import 'package:auth/components/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventWallPost extends StatefulWidget {
  final String caption;
  final String description;
  final String user;
  final String location;
  final String postid;
  final String firstName;
  final List<String> likes;
  final List<String> imageUrls;

  const EventWallPost({
    Key? key,
    required this.caption,
    required this.user,
    required this.postid,
    required this.description,
    required this.location,
    required this.firstName,
    required this.likes,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _EventWallPostState createState() => _EventWallPostState();
}

class _EventWallPostState extends State<EventWallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isliked = false;
  late DocumentReference postRef;
  String? username;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    postRef = FirebaseFirestore.instance.collection('request').doc(widget.postid);

    FirebaseFirestore.instance
        .collection('likes')
        .doc(widget.postid)
        .collection('user_likes')
        .doc(currentUser.uid)
        .get()
        .then((likeSnapshot) {
      if (likeSnapshot.exists) {
        setState(() {
          isliked = true;
        });
      }
    });

    FirebaseFirestore.instance
        .collection('likes')
        .doc(widget.postid)
        .collection('user_likes')
        .get()
        .then((querySnapshot) {
      setState(() {
        likeCount = querySnapshot.docs.length;
      });
    });

    FirebaseFirestore.instance.collection('users').doc(widget.user).get().then((userSnapshot) {
      if (userSnapshot.exists) {
        setState(() {
          username = userSnapshot.data()?['firstName'];
        });
      }
    });
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            "Location : ${widget.location}",
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          if (widget.imageUrls.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.imageUrls
                    .map(
                      (imageUrl) => Container(
                        height: screenHeight * 0.5, // Adjust the height as needed
                        width: screenWidth, // Adjust the width as needed
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16.0),
          Text(likeCount.toString()),
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
            ],
          ),
        ],
      ),
    );
  }
}