// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'UserModel.dart';

class PostModel {
  final String postId;
  final String content;
  final UserModel author;
  final Timestamp timestamp;

  PostModel({
    required this.postId,
    required this.content,
    required this.author,
    required this.timestamp,
  });
}
