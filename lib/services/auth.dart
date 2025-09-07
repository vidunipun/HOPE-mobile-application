import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';
import '../core/result/result.dart';
import '../core/errors/exceptions.dart';

/// Authentication service handling user authentication operations
class AuthService {
  // Private constructor to prevent instantiation
  AuthService._();

  // Singleton instance
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream to get the currently authenticated user
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
        return UserModel(uid: user.uid, email: user.email);
      } catch (e) {
        // Return basic user model if Firestore fetch fails
        return UserModel(uid: user.uid, email: user.email);
      }
    });
  }

  /// Get current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel(uid: user.uid, email: user.email) : null;
  }

  /// Sign in with anonymous account
  Future<Result<UserModel>> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;

      if (user == null) {
        return const Error(message: 'Failed to sign in anonymously');
      }

      return Success(UserModel(uid: user.uid));
    } on FirebaseAuthException catch (e) {
      return Error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return Error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return Error(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  /// Register a new user with email and password
  Future<Result<UserModel>> registerWithEmailAndPassword({
    required String email,
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String address,
    required String password,
    required String idNumber,
    int points = 0,
  }) async {
    try {
      // Validate input
      final validationResult = _validateRegistrationData(
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
        address: address,
        password: password,
        idNumber: idNumber,
      );

      if (validationResult != null) {
        return Error(message: validationResult);
      }

      // Create user account
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return const Error(message: 'Failed to create user account');
      }

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
        address: address,
        idNumber: idNumber,
        points: points,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      return Error(message: _getAuthErrorMessage(e));
    } on FirebaseException catch (e) {
      return Error(message: 'Database error: ${e.message}');
    } catch (e) {
      return Error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return const Error(message: 'Email and password are required');
      }

      if (!_isValidEmail(email)) {
        return const Error(message: 'Please enter a valid email address');
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return const Error(message: 'Failed to sign in');
      }

      // Fetch user data from Firestore
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          return Success(userModel);
        }
      } catch (e) {
        // Return basic user model if Firestore fetch fails
      }

      return Success(UserModel(uid: user.uid, email: user.email));
    } on FirebaseAuthException catch (e) {
      return Error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return Error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<Result<UserModel>> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? address,
    String? profilePictureURL,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (mobileNumber != null) updateData['mobileNumber'] = mobileNumber;
      if (address != null) updateData['address'] = address;
      if (profilePictureURL != null)
        updateData['profilePictureURL'] = profilePictureURL;

      await userRef.update(updateData);

      // Fetch updated user data
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userModel = UserModel.fromFirestore(userDoc);
        return Success(userModel);
      }

      return const Error(message: 'User not found');
    } on FirebaseException catch (e) {
      return Error(message: 'Database error: ${e.message}');
    } catch (e) {
      return Error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get user by UID
  Future<Result<UserModel>> getUserById(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userModel = UserModel.fromFirestore(userDoc);
        return Success(userModel);
      }
      return const Error(message: 'User not found');
    } on FirebaseException catch (e) {
      return Error(message: 'Database error: ${e.message}');
    } catch (e) {
      return Error(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Validate registration data
  String? _validateRegistrationData({
    required String email,
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String address,
    required String password,
    required String idNumber,
  }) {
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Please enter a valid email address';
    if (firstName.isEmpty) return 'First name is required';
    if (lastName.isEmpty) return 'Last name is required';
    if (mobileNumber.isEmpty) return 'Mobile number is required';
    if (address.isEmpty) return 'Address is required';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (idNumber.isEmpty) return 'ID number is required';

    return null;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Get user-friendly error message from Firebase Auth exception
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}

// Legacy class name for backward compatibility
class AuthServices extends AuthService {
  AuthServices() : super._();
}
