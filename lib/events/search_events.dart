import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:csc_picker/csc_picker.dart';

class SearchEventsPage extends StatefulWidget {
  const SearchEventsPage({Key? key}) : super(key: key);

  @override
  _SearchEventsPageState createState() => _SearchEventsPageState();
}

class _SearchEventsPageState extends State<SearchEventsPage> {
  List<String> markersInsideCircle = [];
  GoogleMapController? _mapController;
  LatLng? currentLocation;
  List<Marker> eventMarkers = [];
  LatLng? searchCenter;
  double searchRadius = 0;
  Set<Circle> searchCircles = {};

  final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(0, 0), // Initial map center
    zoom: 12, // Initial zoom level
  );
  
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final locationPermissionStatus = await Permission.location.request();
    if (locationPermissionStatus.isGranted) {
      _getCurrentLocation();
      _getEventLocations();
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude.toDouble(), position.longitude.toDouble());
    });
    _mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));

    // Fetch event locations and add markers
    await _getEventLocations();

  }

  Future<void> _getEventLocations() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Events').get();

    Set<Marker>_markers = {};

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String location = doc['location'];
      String eventCaption = doc['caption'];

      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        Location eventLocation = locations.first;

        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(eventLocation.latitude, eventLocation.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: eventCaption,
            ),
          ),
        );
      }
    }

    setState(() {
      eventMarkers = _markers.toList();
    });
  }

void _searchNearbyEvents() {
    String? selectedCountry = '';
    String? selectedState = '';
    String? selectedCity = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Nearby Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                margin: EdgeInsets.all(20),
                child: CSCPicker(
                  layout: Layout.vertical,
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
              TextField(
                decoration:
                    InputDecoration(labelText: 'Search Radius (in meters)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final radius = double.tryParse(value);
                  setState(() {
                    searchRadius = radius ?? 0;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _drawSearchCircle(selectedCountry, selectedState, selectedCity);
                Navigator.of(context).pop();
                //_openBottomSheet(); // Call _openBottomSheet after closing the dialog
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _openBottomSheet() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        // Build your bottom sheet content here
        child: Text('Bottom Sheet Content'),
      );
    },
  );
}

void _drawSearchCircle(
  String? selectedCountry, String? selectedState, String? selectedCity) {
  
  String location = '$selectedCity, $selectedState, $selectedCountry';

  locationFromAddress(location).then((locations) {
    if (locations.isNotEmpty) {
      Location searchLocation = locations.first;
      setState(() {
        searchCenter = LatLng(searchLocation.latitude, searchLocation.longitude);
      });

      final circle = Circle(
        circleId: CircleId('searchCircle'),
        center: searchCenter!,
        radius: searchRadius,
        strokeWidth: 2,
        strokeColor: Color.fromRGBO(33, 150, 243, 1),
        fillColor: Colors.blue.withOpacity(0.2),
      );

      setState(() {
        searchCircles = {circle};
      });

      // Get markers inside the circle
      List<String> markersInsideCircle = [];
      for (Marker marker in eventMarkers) {
        double distance = Geolocator.distanceBetween(
          searchCenter!.latitude,
          searchCenter!.longitude,
          marker.position.latitude,
          marker.position.longitude,
        );

        if (distance <= searchRadius) {
          markersInsideCircle.add(marker.markerId.value);
        }
      }

      // Do something with the markers inside the circle (e.g., print their names)
      print('Markers inside the circle 1: $markersInsideCircle');

      //_buildBottomSheet: _buildBottomSheet();
      _buildBottomAppBar(context, markersInsideCircle);

      
      
    } else {
      // Handle case when location is not found
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Not Found'),
            content: Text('The selected location was not found.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search Events'),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              markers: {
                if (currentLocation != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: currentLocation!,
                  ),
                ...eventMarkers,
              },
                circles: searchCircles,
                
                myLocationEnabled: true, // Enable the "My Location" button
                myLocationButtonEnabled: true, // Enable the "My Location" button
            ),
          Positioned(
            top: 5,
            right: 215,
            child: ElevatedButton(
              onPressed: _searchNearbyEvents,
              child: Text('Search Nearby Events'),
            ),
          ),
          

          // Bottom App Bar
          _buildBottomSheet(context),
          
        ],
      ),
      
    );
  }

  @override
Widget _buildBottomSheet(BuildContext context) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: GestureDetector(
      onTap: () {
        // Check if the bottom sheet is already open
        if (ModalRoute.of(context)?.isCurrent == false) {
          // Bottom sheet is open, close it
          Navigator.pop(context);
        }
      },
      child: Container(
        child: _buildBottomAppBar(context,markersInsideCircle),
      ),
    ),
  );
}

Widget _buildBottomAppBar(BuildContext context,List<String> markersInsideCircle ) {
   print('Markers inside the circle 2: $markersInsideCircle');
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              // Customize the appearance of the expanded bottom sheet as desired
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                      child: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('Events').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      List<String> captions = snapshot.data!.docs
          .map((doc) => doc['caption'].toString())
          .toList();
      List<String> filteredCaptions = captions
          .where((caption) => markersInsideCircle.contains(caption))
          .toList();
      
      _buildCaptionList(filteredCaptions);
      
      print('Markers inside the circle 3: $markersInsideCircle');
      
      return Container();
    } else {
      return Center(child: CircularProgressIndicator());
    }
  },
),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    
    child: Container(
      // Your bottom app bar content and layout
      height: 45.0, // Adjust the height as needed
      color: Colors.blue, // Customize the background color
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            ' Your Nereby Events',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
   

Widget _buildCaptionList(List<String> filteredCaptions) {
  print('Your Nearby Events: $filteredCaptions');
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: filteredCaptions.length, 
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(filteredCaptions[index]),
      );
    },
  );
}
} 






































// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart';
// import 'dart:io';
// import 'package:csc_picker/csc_picker.dart';

// class SearchEventsPage extends StatefulWidget {
//   const SearchEventsPage({Key? key}) : super(key: key);

//   @override
//   _SearchEventsPageState createState() => _SearchEventsPageState();
// }

// class _SearchEventsPageState extends State<SearchEventsPage> {
//   GoogleMapController? _mapController;
//   LatLng? currentLocation;
//   List<Marker> eventMarkers = [];
//   LatLng? searchCenter;
//   double searchRadius = 0;
//   Set<Circle> searchCircles = {};

//   final CameraPosition initialCameraPosition = CameraPosition(
//     target: LatLng(0, 0), // Initial map center
//     zoom: 12, // Initial zoom level
//   );

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermission();
//   }

//   Future<void> _checkLocationPermission() async {
//     final locationPermissionStatus = await Permission.location.request();
//     if (locationPermissionStatus.isGranted) {
//       _getCurrentLocation();
//       _getEventLocations();
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       currentLocation = LatLng(position.latitude.toDouble(), position.longitude.toDouble());
//     });
//     _mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));

//     // Fetch event locations and add markers
//     await _getEventLocations();

//   }

//   Future<void> _getEventLocations() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Events').get();

//     Set<Marker>_markers = {};

//     for (QueryDocumentSnapshot doc in snapshot.docs) {
//       String location = doc['location'];
//       String eventCaption = doc['caption'];

//       List<Location> locations = await locationFromAddress(location);
//       if (locations.isNotEmpty) {
//         Location eventLocation = locations.first;

//         _markers.add(
//           Marker(
//             markerId: MarkerId(doc.id),
//             position: LatLng(eventLocation.latitude, eventLocation.longitude),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//             infoWindow: InfoWindow(
//               title: eventCaption,
//             ),
//           ),
//         );
//       }
//     }

//     setState(() {
//       eventMarkers = _markers.toList();
//     });
//   }

// void _searchNearbyEvents() {
//     String? selectedCountry = '';
//     String? selectedState = '';
//     String? selectedCity = '';

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Search Nearby Events'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Select Location',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20.0,
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Container(
//                 margin: EdgeInsets.all(20),
//                 child: CSCPicker(
//                   layout: Layout.vertical,
//                   onCountryChanged: (country) {
//                     setState(() {
//                       selectedCountry = country;
//                     });
//                   },
//                   onStateChanged: (state) {
//                     setState(() {
//                       selectedState = state;
//                     });
//                   },
//                   onCityChanged: (city) {
//                     setState(() {
//                       selectedCity = city;
//                     });
//                   },
//                 ),
//               ),
//               TextField(
//                 decoration:
//                     InputDecoration(labelText: 'Search Radius (in meters)'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   final radius = double.tryParse(value);
//                   setState(() {
//                     searchRadius = radius ?? 0;
//                   });
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _drawSearchCircle(selectedCountry, selectedState, selectedCity);
//                 Navigator.of(context).pop();
//                 _openBottomSheet(); // Call _openBottomSheet after closing the dialog
//               },
//               child: Text('Search'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _openBottomSheet() {
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         // Build your bottom sheet content here
//         child: Text('Bottom Sheet Content'),
//       );
//     },
//   );
// }

// void _drawSearchCircle(
//   String? selectedCountry, String? selectedState, String? selectedCity) {
  
//   String location = '$selectedCity, $selectedState, $selectedCountry';

//   locationFromAddress(location).then((locations) {
//     if (locations.isNotEmpty) {
//       Location searchLocation = locations.first;
//       setState(() {
//         searchCenter = LatLng(searchLocation.latitude, searchLocation.longitude);
//       });

//       final circle = Circle(
//         circleId: CircleId('searchCircle'),
//         center: searchCenter!,
//         radius: searchRadius,
//         strokeWidth: 2,
//         strokeColor: Color.fromRGBO(33, 150, 243, 1),
//         fillColor: Colors.blue.withOpacity(0.2),
//       );

//       setState(() {
//         searchCircles = {circle};
//       });

//       // Get markers inside the circle
//       List<String> markersInsideCircle = [];
//       for (Marker marker in eventMarkers) {
//         double distance = Geolocator.distanceBetween(
//           searchCenter!.latitude,
//           searchCenter!.longitude,
//           marker.position.latitude,
//           marker.position.longitude,
//         );

//         if (distance <= searchRadius) {
//           markersInsideCircle.add(marker.markerId.value);
//         }
//       }

//       // Do something with the markers inside the circle (e.g., print their names)
//       print('Markers inside the circle: $markersInsideCircle');

//       //_buildBottomSheet: _buildBottomSheet();

      
      
//     } else {
//       // Handle case when location is not found
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Location Not Found'),
//             content: Text('The selected location was not found.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Search Events'),
//         ),
//         body: Stack(
//           children: [
//             GoogleMap(
//               initialCameraPosition: initialCameraPosition,
//               onMapCreated: (controller) {
//                 setState(() {
//                   _mapController = controller;
//                 });
//               },
//               markers: {
//                 if (currentLocation != null)
//                   Marker(
//                     markerId: MarkerId('currentLocation'),
//                     position: currentLocation!,
//                   ),
//                 ...eventMarkers,
//               },
//                 circles: searchCircles,
                
//                 myLocationEnabled: true, // Enable the "My Location" button
//                 myLocationButtonEnabled: true, // Enable the "My Location" button
//             ),
//           Positioned(
//             top: 5,
//             right: 215,
//             child: ElevatedButton(
//               onPressed: _searchNearbyEvents,
//               child: Text('Search Nearby Events'),
//             ),
//           ),
          

//           // Bottom App Bar
//           _buildBottomSheet(context),
//           // Additional Bottom App Bar Widget
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               height: 40.0,
//               color: const Color.fromRGBO(33, 150, 243, 1),
//               child: Center(
//                 child: Text(
//                   'Additional Bottom App Bar',
//                   style: TextStyle(color: Colors.white, fontSize: 16.0),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
// Widget _buildBottomSheet(BuildContext context) {
//   return GestureDetector(
//     onTap: () {
//       // Check if the bottom sheet is already open
//       if (ModalRoute.of(context)?.isCurrent == false) {
//         // Bottom sheet is open, close it
//         Navigator.pop(context);
//       }
//       },
//       child: Container(
//       child: _buildBottomAppBar(context),
//       ),
//     );
// }

// Widget _buildBottomAppBar(BuildContext context) {
//   return GestureDetector(
//     onTap: () {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return SingleChildScrollView(
//             child: Container(
//               // Customize the appearance of the expanded bottom sheet as desired
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10.0),
//                   topRight: Radius.circular(10.0),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Container(
//                     height: 8.0,
//                     decoration: BoxDecoration(
//                       color: Colors.grey,
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance.collection('Events').snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           List<String> captions = snapshot.data!.docs.map((doc) => doc['caption'].toString()).toList();
//                           return _buildCaptionList(captions);
//                         } else {
//                           return Center(child: CircularProgressIndicator());
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     },
//     child: Container(
//       // Your bottom app bar content and layout
//       height: 56.0, // Adjust the height as needed
//       color: Colors.blue, // Customize the background color
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () {
//               // Handle menu button tap
//             },
//           ),
//           Text(
//             'Bottom App Bar',
//             style: TextStyle(
//               fontSize: 16.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               // Handle search button tap
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }
   

// Widget _buildCaptionList(List<String> captions) {
//   return ListView.builder(
//     shrinkWrap: true,
//     physics: NeverScrollableScrollPhysics(),
//     itemCount: captions.length,
//     itemBuilder: (context, index) {
//       return ListTile(
//         title: Text(captions[index]),
//       );
//     },
//   );
// }

// }