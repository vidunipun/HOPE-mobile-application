import 'package:auth/constants/colors.dart';
import 'package:auth/events/events_wall.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth/screens/home/wall/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:csc_picker/csc_picker.dart';

class AddEventsPage extends StatefulWidget {
  const AddEventsPage({Key? key}) : super(key: key);

  @override
  State<AddEventsPage> createState() => _AddEventsPageState();
}

class _AddEventsPageState extends State<AddEventsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  //final TextEditingController _confirmationController = TextEditingController();
  //final AuthServices _auth = AuthServices();
  final currentUser = FirebaseAuth.instance.currentUser;

  String? selectedCountry = '';
  String? selectedState = '';
  String? selectedCity = '';
  String? _firstName;

  User? user;

  final List<File> _selectedImages = [];
  final List<String> _uploadedFileUrls = [];

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
      String tags = _tagsController.text;
      String location = _locationController.text;
      //String confirmation = _confirmationController.text;

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

      try {
        // Get the authenticated user
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Save data to Firestore with the user's ID
          DocumentReference requestDocRef =
              FirebaseFirestore.instance.collection('Events').doc();
          await requestDocRef.set({
            'userId': user.uid,
            'caption': caption,
            'description': description,
            'tags': tags,
            'location': location,
            //'confirmation': confirmation,
            //'timestamp': FieldValue.serverTimestamp(),
            'tick': tick,
            'UserEmail': currentUser?.email,
            'firstName': _firstName,
            'TimeStamp': Timestamp.now(),
            'Likes': [],
          });

          // Upload selected images to Firebase Storage
          for (File image in _selectedImages) {
            String imageName = image.path.split('/').last;
            firebase_storage.Reference storageRef = firebase_storage
                .FirebaseStorage.instance
                .ref()
                .child('Events')
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
                  /* countryDropdownLabel: "*Country",
          stateDropdownLabel: "*State",
          cityDropdownLabel: "*City",*/
                  //dropdownDialogRadius: 30,
                  //searchBarRadius: 30,
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
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _captionController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
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
                      // Open the location model
                      _openLocationModel();
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _selectImage,
                    child: const Text(
                      'Add Post',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonbackground,
                      side: BorderSide(color: buttonboarder, width: 2),
                    ),
                  ),
                  _selectedImages.isNotEmpty
                      ? Column(
                          children: _selectedImages
                              .map((image) => Image.file(image))
                              .toList(),
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: _uploadImages,
                  //   child: const Text('Upload Images'),
                  // ),
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

                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      await _submitRequest();
                      await _uploadImages();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const EventHome(),
                        ),
                      );
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonbackground,
                      side: BorderSide(color: buttonboarder, width: 2),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
