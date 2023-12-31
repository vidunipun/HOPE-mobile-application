// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:auth/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _imageFile; // Selected image file
  final ImagePicker _imagePicker = ImagePicker();
  String? profilePictureURL;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _selectImage() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadProfileImageAndSaveChanges() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      if (_imageFile != null) {
        final Reference storageReference =
            FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
        final UploadTask uploadTask = storageReference.putFile(_imageFile!);

        await uploadTask.whenComplete(() async {
          final url = await storageReference.getDownloadURL();

          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'profilePictureURL': url,
          });

          updateProfileData();
          Navigator.pop(context);
        });
      } else {
        updateProfileData();
        Navigator.pop(context);
      }
    }
  }

  void updateProfileData() {
    final String newFirstName = _fnameController.text;
    final String newLastName = _lnameController.text;
    final String newMobileNumber = _mobileNumberController.text;
    final String newAddress = _addressController.text;

    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': newFirstName,
        'lastName': newLastName,
        'mobileNumber': newMobileNumber,
        'address': newAddress,
      });
    }
  }

  Future<void> fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        final Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        _fnameController.text = userData['firstName'] ?? '';
        _lnameController.text = userData['lastName'] ?? '';
        _mobileNumberController.text = userData['mobileNumber'] ?? '';
        _addressController.text = userData['address'] ?? '';
        profilePictureURL = userData['profilePictureURL'];
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonbackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Back',
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _selectImage,
                  child: ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: profilePictureURL != null
                              ? NetworkImage(profilePictureURL!)
                              : (_imageFile != null
                                  ? FileImage(_imageFile!)
                                      as ImageProvider<Object>
                                  : const AssetImage('assets/register.png')),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _fnameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: 'Enter your first name',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: 'Enter your last name',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: 'Enter your mobile number',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: 'Enter your address',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                    onPressed: _uploadProfileImageAndSaveChanges,
                    style: ElevatedButton.styleFrom(
                      primary: buttonboarder, // Set the button color to #0BFFFF
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: buttonbackground,
                        fontSize: 20,
                        fontFamily: 'Otomanopee One',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
