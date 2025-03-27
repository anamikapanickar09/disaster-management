import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

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
  String mapUrlTemplate = "https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}"; // "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png";

  @override
  void initState() {
    super.initState();
    requestLocationAccess();
    fetchMapData();
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

  void fetchMapData() {
    FirebaseFirestore.instance
        .collection('alerts')
        .snapshots()
        .listen((snapshot) {
      List<dynamic> unClosedAlerts = snapshot.docs.where((i) => i['closed'] == false).toList();
      List<Marker> alertMarkers = unClosedAlerts.map((doc) {
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
            child: Icon(Icons.location_on, color: data['committed'] ? Colors.yellow[800] : Colors.red, size: 40),
          ),
        );
      }).toList();

      FirebaseFirestore.instance
          .collection('camps')
          .snapshots()
          .listen((snapshot) {
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
              child: const Icon(Icons.local_hospital,
                  color: Colors.green, size: 40),
            ),
          );
        }).toList();

        setState(() {
          markers = [...alertMarkers, ...campMarkers];
        });
      });
    });
  }

  void searchAndZoom(String query) {
    final searchResults = markers.where((marker) {
      final point = marker.point.toString();
      return point.contains(query);
    }).toList();

    if (searchResults.isNotEmpty) {
      _mapController.move(searchResults.first.point, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching locations found')),
      );
    }
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
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
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchAndZoom(searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLocation ?? LatLng(10.0, 76.0),
                initialZoom: 10.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapUrlTemplate,
                  subdomains: ['0', '1', '2', '3'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
