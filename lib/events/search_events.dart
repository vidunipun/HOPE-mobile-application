// ignore_for_file: avoid_print, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_element

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:csc_picker/csc_picker.dart';

class SearchEventsPage extends StatefulWidget {
  const SearchEventsPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchEventsPageState createState() => _SearchEventsPageState();
}

class _SearchEventsPageState extends State<SearchEventsPage> {
  List<String> markersInsideCircle = <String>[];
  GoogleMapController? _mapController;
  LatLng? currentLocation;
  List<Marker> eventMarkers = [];
  LatLng? searchCenter;
  double searchRadius = 0;
  Set<Circle> searchCircles = {};

  final CameraPosition initialCameraPosition = const CameraPosition(
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
      currentLocation =
          LatLng(position.latitude.toDouble(), position.longitude.toDouble());
    });
    _mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));

    // Fetch event locations and add markers
    await _getEventLocations();
  }

  Future<void> _getEventLocations() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Events').get();

    Set<Marker> _markers = {};

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String location = doc['location'];
      String eventCaption = doc['caption'];
      //print('location');
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        Location eventLocation = locations.first;

        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(eventLocation.latitude, eventLocation.longitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
          title: const Text('Search Nearby Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                margin: const EdgeInsets.all(20),
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
                decoration: const InputDecoration(
                    labelText: 'Search Radius (in meters)'),
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
              child: const Text('Search'),
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
        return const Text('Bottom Sheet Content');
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
          searchCenter =
              LatLng(searchLocation.latitude, searchLocation.longitude);
        });

        final circle = Circle(
          circleId: const CircleId('searchCircle'),
          center: searchCenter!,
          radius: searchRadius,
          strokeWidth: 2,
          strokeColor: const Color.fromRGBO(33, 150, 243, 1),
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
        // _buildBottomAppBar(context, markersInsideCircle);
        //_buildBottomSheet(context,markersInsideCircle);
      } else {
        // Handle case when location is not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Not Found'),
              content: const Text('The selected location was not found.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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
    print('come to dubai');
    print('Markers inside the circle 1: $markersInsideCircle');
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
                  markerId: const MarkerId('currentLocation'),
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
              child: const Text('Search Nearby Events'),
            ),
          ),

          // Bottom App Bar
          _buildBottomSheet(context, markersInsideCircle),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, markersInsideCircle) {
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
          child: _buildBottomAppBar(context, markersInsideCircle),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(
      BuildContext context, List<String> markersInsideCircle) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.5, // Adjust the height factor as desired
              child: SingleChildScrollView(
                child: Container(
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
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Your Nearby Events',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   markersInsideCircle.toString(),
                            //   style: TextStyle(
                            //     fontSize: 16.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ],
                        ),
                      )
//                    ListView.builder(
//   shrinkWrap: true,
//   itemCount: markersInsideCircle.length,
//   itemBuilder: (context, index) {
//     List<String> items = ['book', 'table', 'shadow', 'baby'];
//     Color: Colors.black;
//     return ListTile(
//       leading: const Icon(Icons.location_on),
//       title: Text(items[index]),
//       trailing: const Icon(Icons.arrow_forward),
//       onTap: () {
//         // Handle onTap behavior for each marker
//         print('Tapped Marker ${items[index]}');
//       },
//     );
//   },
// ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 45.0,
        color: Colors.blue,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Nearby Events',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 0, 0),
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
      physics: const NeverScrollableScrollPhysics(),
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart';
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