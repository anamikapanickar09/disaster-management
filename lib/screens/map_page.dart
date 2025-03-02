import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  void fetchAlerts() {
    FirebaseFirestore.instance
        .collection('alerts')
        .snapshots()
        .listen((snapshot) {
      final newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Marker(
          width: 40,
          height: 40,
          point: LatLng(data['latitude'], data['longitude']),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Emergency Alert"),
                  content: Text(data['comment']),
                ),
              );
            },
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      }).toList();

      setState(() => markers = newMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map View")),
      body: FlutterMap(
        options:
            MapOptions(initialCenter: LatLng(10.0, 76.0), initialZoom: 10.0),
        children: [
          TileLayer(
            urlTemplate:
                "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
