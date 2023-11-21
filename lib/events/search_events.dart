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
      String eventDescription = doc['description'];
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
              snippet: '$location\n$eventDescription',
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

        print('Markers inside the circle 1: $markersInsideCircle');
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
        ],
      ),
    );
  }
}
