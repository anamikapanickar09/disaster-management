import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];
  final MapController _mapController = MapController();
  LatLng? userLocation;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> placesList = [];

  @override
  void initState() {
    super.initState();
    fetchMapData();
  }

  void fetchMapData() {
    FirebaseFirestore.instance.collection('alerts').snapshots().listen((snapshot) {
      List<Marker> alertMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        final comment = data['comment'] ?? "No comment";
        final latitude = data['latitude'] ?? 0.0;
        final longitude = data['longitude'] ?? 0.0;

        return Marker(
          width: 40,
          height: 40,
          point: LatLng(latitude, longitude),
          child: GestureDetector(
            onTap: () => _showInfoDialog("Emergency Alert", comment),
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      }).toList();

      FirebaseFirestore.instance.collection('camps').snapshots().listen((snapshot) {
        List<Marker> campMarkers = snapshot.docs.map((doc) {
          final data = doc.data();
          final comment = data['comment'] ?? "No comment";
          final latitude = data['latitude'] ?? 0.0;
          final longitude = data['longitude'] ?? 0.0;

          return Marker(
            width: 40,
            height: 40,
            point: LatLng(latitude, longitude),
            child: GestureDetector(
              onTap: () => _showInfoDialog("Camp Location", comment),
              child: const Icon(Icons.local_hospital, color: Colors.blue, size: 40),
            ),
          );
        }).toList();

        setState(() {
          markers = [...alertMarkers, ...campMarkers]; // Combine both markers
          updatePlacesList();
        });

        if (markers.isNotEmpty) zoomToNearestMarker();
      });
    });
  }

  void updatePlacesList() {
    placesList = markers.map((marker) {
      return {
        'name': "Marker at (${marker.point.latitude}, ${marker.point.longitude})",
        'location': marker.point
      };
    }).toList();
  }

  void zoomToNearestMarker() {
    if (markers.isEmpty) return;
    LatLng nearestMarker = markers.first.point;
    _mapController.move(nearestMarker, 15.0);
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng searchedLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.move(searchedLocation, 15.0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found!")),
      );
    }
  }

  void zoomToMarker(LatLng location) {
    _mapController.move(location, 15.0);
  }

  Future<void> requestLocationAccess() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      userLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    zoomToUserLocation();
  }

  void zoomToUserLocation() {
    if (userLocation != null) {
      _mapController.move(userLocation!, 15.0);
    }
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map View", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField<Map<String, dynamic>>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Places & Markers",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              suggestionsCallback: (pattern) {
                return placesList.where((place) =>
                    place['name'].toLowerCase().contains(pattern.toLowerCase()));
              },
              itemBuilder: (context, Map<String, dynamic> suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(suggestion['name']),
                );
              },
              onSuggestionSelected: (Map<String, dynamic> suggestion) {
                searchController.text = suggestion['name'];
                zoomToMarker(suggestion['location']);
              },
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: requestLocationAccess,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      markers.isNotEmpty ? markers.first.point : LatLng(10.0, 76.0),
                  initialZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
