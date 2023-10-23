// ignore_for_file: unnecessary_new, avoid_print, non_constant_identifier_names, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, deprecated_member_use, use_build_context_synchronously, duplicate_ignore

import 'dart:convert';
import 'package:auth/constants/colors.dart';
import 'package:auth/constants/colors.dart';
import 'package:auth/screens/home/wall/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:csc_picker/csc_picker.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({Key? key}) : super(key: key);

  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contacController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  //final TextEditingController _confirmationController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  //final AuthServices _auth = AuthServices();
  final currentUser = FirebaseAuth.instance.currentUser;

  String? selectedCountry = '';
  String? selectedState = '';
  String? selectedCity = '';
  String? _firstName;

  User? user;

  final List<File> _selectedImages = [];
  final List<String> _uploadedFileUrls = [];

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = new ImagePicker();

//get image from drive
  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imagepath = File(getimage!.path);
      imagename = getimage.path.split('/').last;
      imagedata = base64Encode(imagepath!.readAsBytesSync());
      print(imagepath);
      print(imagename);
      print(imagedata);
    });
  }

  bool _isInformationCorrect = false;

  get tick => null;
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot userSnapshot = await users.doc(uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _firstName = userData['firstName'] ?? '';
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      String caption = _captionController.text;
      String description = _descriptionController.text;
      String contact = _contacController.text;
      String location = _locationController.text;

      String? amount =
          _amountController.text.isNotEmpty ? _amountController.text : null;

      if (!_isInformationCorrect) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verify Information'),
              content: const Text(
                  'Please verify that all the information is correct.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        // ignore: unused_local_variable
        bool tick = _isInformationCorrect;
        return;
      }

      await _uploadImages();
      try {
        // Get the authenticated user
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Save data to Firestore with the user's ID
          DocumentReference requestDocRef =
              FirebaseFirestore.instance.collection('requests').doc();
          await requestDocRef.set({
            'userId': user.uid,
            'caption': caption,
            'description': description,
            'conatct': contact,
            'location': location,
            //'confirmation': confirmation,
            //'timestamp': FieldValue.serverTimestamp(),
            'tick': tick,
            'UserEmail': currentUser?.email,
            'firstName': _firstName,
            'TimeStamp': FieldValue.serverTimestamp(),
            'amount': amount,
            'to_now': 0,
            // 'Likes': [],
          });
          FirebaseFirestore.instance.collection('requests').add({'Likes': []});

          // Upload selected images to Firebase Storage
          for (File image in _selectedImages) {
            String imageName = image.path.split('/').last;
            firebase_storage.Reference storageRef = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child('requests')
                .child(requestDocRef.id)
                .child(imageName);
            await storageRef.putFile(image);
            String downloadURL = await storageRef.getDownloadURL();
            print('Image uploaded: $downloadURL');
            // Add the download URL to the request document in Firestore
            await requestDocRef.update({
              'selectedImagesUrls': FieldValue.arrayUnion([downloadURL]),
            });

            setState(() {
              _uploadedFileUrls.add(downloadURL);
            });
          }

          // Data saved successfully
          print('Data saved to Firestore');

          // Reset the form or navigate to another page as needed
        } else {
          // User is not authenticated, handle this case
          print('User is not authenticated');
        }
      } catch (e) {
        // Handle errors if data couldn't be saved
        print('Error saving data to Firestore: $e');
      }
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _uploadImages() async {
    for (File image in _selectedImages) {
      String imageName = image.path.split('/').last;
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images')
          .child(imageName);
      await storageRef.putFile(image);
      String downloadURL = await storageRef.getDownloadURL();
      print('Image uploaded: $downloadURL');
      // Add the download URL to the list of uploaded file URLs
      setState(() {
        _uploadedFileUrls.add(downloadURL);
      });
    }
  }

  void _openLocationModel() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Select Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 16.0),
              // Your custom model content goes here
              // You can add buttons, text fields, or any other widgets to select the location
              // For example, you can use a TextFormField or a DropdownButtonFormField
              Container(
                margin: const EdgeInsets.all(20),
                child: CSCPicker(
                  layout: Layout.vertical,
                  //flagState: CountryFlag.DISABLE,
                  onCountryChanged: (country) {
                    setState(() {
                      selectedCountry = country;
                    });
                  },
                  onStateChanged: (state) {
                    setState(() {
                      selectedState = state;
                    });
                  },
                  onCityChanged: (city) {
                    setState(() {
                      selectedCity = city;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Save the selected location from the model
                  String? SelectedLocation =
                      '$selectedCountry, $selectedState, $selectedCity';
                  // Update the location controller in the main form
                  _locationController.text = SelectedLocation;
                  // Close the model
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonbackground,
      // appBar: AppBar(
      //   title: const Text('Donation Page'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Row(
                 children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Back',
                ),
                Text(
                  'Add Events',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
              ),
              Row(
                
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _captionController,
                      decoration: InputDecoration(
                          labelText: 'Caption',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a caption';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      color: buttonboarder,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Caption Guidance'),
                            content: const Text('Enter a caption of the post.'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Caption Guidance',
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      color: buttonboarder,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Description Guidance'),
                            content: const Text(
                                'Enter a detailed description of the post.'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Description Guidance',
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contacController,
                      decoration: InputDecoration(
                          labelText: 'Contact',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid contact number';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      color: buttonboarder,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Contact Guidance'),
                            content: const Text(
                                'Enter a valid contact number for inquiries.'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Contact Guidance',
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                      onTap: () {
                        _openLocationModel();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      color: buttonboarder,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Location Guidance'),
                            content:
                                const Text('Enter the related location of the post.'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Location Guidance',
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              imagepath != null
                  ? SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.file(imagepath!),
                    )
                  : Text(
                      "Image not chosen yet",
                      style: TextStyle(color: Colors.white),
                    ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: _selectImage,
                style: ElevatedButton.styleFrom(
                  primary: buttonboarder, // Set the button color to #0BFFFF
                ),
                child: Text(
                  ' Add Post Image',
                  style: TextStyle(
                    color: buttonbackground,
                    fontSize: 20,
                    fontFamily: 'Otomanopee One',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
              _selectedImages.isNotEmpty
                  ? Column(
                      children: _selectedImages
                          .map((image) => SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.file(image, fit: BoxFit.cover),
                              ))
                          .toList(),
                    )
                  : Container(), // Optionally display a placeholder if there are no selected images

              const SizedBox(height: 10),

              Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: CheckboxListTile(
                  title: Text(
                    'I verify that all the information is correct',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _isInformationCorrect,
                  onChanged: (value) {
                    setState(() {
                      _isInformationCorrect = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _submitRequest();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonboarder, // Set the button color to #0BFFFF
                ),
                child: Text(
                  ' Submit',
                  style: TextStyle(
                    color: buttonbackground,
                    fontSize: 20,
                    fontFamily: 'Otomanopee One',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}