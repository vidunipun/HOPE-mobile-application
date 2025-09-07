import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a user in the HOPE application
class UserModel {
  final String uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? mobileNumber;
  final String? address;
  final String? idNumber;
  final String? profilePictureURL;
  final int points;
  final String? rank;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const UserModel({
    required this.uid,
    this.email,
    this.firstName,
    this.lastName,
    this.mobileNumber,
    this.address,
    this.idNumber,
    this.profilePictureURL,
    this.points = 0,
    this.rank,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel(uid: doc.id);
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      mobileNumber: data['mobileNumber'] as String?,
      address: data['address'] as String?,
      idNumber: data['idnumber'] as String?,
      profilePictureURL: data['profilePictureURL'] as String?,
      points: data['points'] as int? ?? 0,
      rank: data['rank'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  /// Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      address: map['address'] as String?,
      idNumber: map['idnumber'] as String?,
      profilePictureURL: map['profilePictureURL'] as String?,
      points: map['points'] as int? ?? 0,
      rank: map['rank'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'address': address,
      'idnumber': idNumber,
      'profilePictureURL': profilePictureURL,
      'points': points,
      'rank': rank,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Unknown User';
  }

  /// Get display name (first name or email)
  String get displayName {
    return firstName ?? email ?? 'Unknown User';
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? address,
    String? idNumber,
    String? profilePictureURL,
    int? points,
    String? rank,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      idNumber: idNumber ?? this.idNumber,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, points: $points)';
  }
}
