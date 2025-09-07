import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserModel.dart';

/// Post model representing a post in the HOPE application
class PostModel {
  final String postId;
  final String content;
  final String? description;
  final String? location;
  final String? amount;
  final List<String> imageUrls;
  final List<String> likes;
  final UserModel author;
  final Timestamp timestamp;
  final Timestamp? updatedAt;
  final String? type; // 'donation', 'request', 'event', 'general'

  const PostModel({
    required this.postId,
    required this.content,
    this.description,
    this.location,
    this.amount,
    this.imageUrls = const [],
    this.likes = const [],
    required this.author,
    required this.timestamp,
    this.updatedAt,
    this.type,
  });

  /// Create PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Post data is null');
    }

    return PostModel(
      postId: doc.id,
      content: data['content'] as String? ?? '',
      description: data['description'] as String?,
      location: data['location'] as String?,
      amount: data['amount'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      author: UserModel.fromMap(data['author'] as Map<String, dynamic>),
      timestamp: data['timestamp'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp?,
      type: data['type'] as String?,
    );
  }

  /// Create PostModel from Map
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] as String,
      content: map['content'] as String? ?? '',
      description: map['description'] as String?,
      location: map['location'] as String?,
      amount: map['amount'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      author: UserModel.fromMap(map['author'] as Map<String, dynamic>),
      timestamp: map['timestamp'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp?,
      type: map['type'] as String?,
    );
  }

  /// Convert PostModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'content': content,
      'description': description,
      'location': location,
      'amount': amount,
      'imageUrls': imageUrls,
      'likes': likes,
      'author': author.toMap(),
      'timestamp': timestamp,
      'updatedAt': updatedAt,
      'type': type,
    };
  }

  /// Check if user has liked this post
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Get like count
  int get likeCount => likes.length;

  /// Check if post has images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Get first image URL
  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Create a copy of PostModel with updated fields
  PostModel copyWith({
    String? postId,
    String? content,
    String? description,
    String? location,
    String? amount,
    List<String>? imageUrls,
    List<String>? likes,
    UserModel? author,
    Timestamp? timestamp,
    Timestamp? updatedAt,
    String? type,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      content: content ?? this.content,
      description: description ?? this.description,
      location: location ?? this.location,
      amount: amount ?? this.amount,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.postId == postId;
  }

  @override
  int get hashCode => postId.hashCode;

  @override
  String toString() {
    return 'PostModel(postId: $postId, content: $content, author: ${author.displayName}, likes: $likeCount)';
  }
}
