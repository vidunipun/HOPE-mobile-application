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
  final String lastName;
  final List<String> likes;
  final List<String> imageUrls;
  final String? profilePictureURL;

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
    required this.lastName,
    this.profilePictureURL,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
    postRef =
        FirebaseFirestore.instance.collection('request').doc(widget.postid);

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
            children: [
              if (widget.profilePictureURL != null &&
                  widget.profilePictureURL!.isNotEmpty)
                CircleAvatar(
                  radius: 24, //   size
                  backgroundImage: NetworkImage(widget.profilePictureURL!),
                ),
              if (widget.profilePictureURL != null &&
                  widget.profilePictureURL!.isNotEmpty)
                const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Text(
                widget.firstName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                widget.lastName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  //color: Colors.grey[300],
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
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
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${widget.description}",
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 28, // Set your desired icon color
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location:",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${widget.location}",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.imageUrls.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.imageUrls
                    .map(
                      (imageUrl) => SizedBox(
                        height:
                            screenHeight * 0.5, // Adjust the height as needed
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
