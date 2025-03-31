import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.focusLocation = null});
  final LatLng? focusLocation;
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];
  final MapController _mapController = MapController();
  LatLng? userLocation;
  TextEditingController searchController = TextEditingController();
  String mapUrlTemplate =
      "https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
  // String mapUrlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png";
  var firebaseSubscription;

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
    if (mounted) {
      setState(() {
        userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    }

    zoomToUserLocation();
  }

  void zoomToUserLocation() {
    if (widget.focusLocation != null) {
      _mapController.move(widget.focusLocation!, 18);
    } else if (userLocation != null) {
      _mapController.move(userLocation!, 15.0);
    }
  }

  void fetchMapData() {
    firebaseSubscription = FirebaseFirestore.instance
        .collection('alerts')
        .where('closed', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
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
            onTap: () => _showInfoDialog(data),
            child: Icon(Icons.location_on,
                color: data['committed'] ? Colors.yellow[800] : Colors.red,
                size: 35),
          ),
        );
      }).toList();

      FirebaseFirestore.instance
          .collection('camps')
          .where('is_open', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        List<Marker> campMarkers = snapshot.docs.map((doc) {
          print("running bruh");
          final data = doc.data();
          final comment = data['comment'] ?? "No comment";
          final latitude = data['latitude'] ?? 0.0;
          final longitude = data['longitude'] ?? 0.0;

          return Marker(
            width: 40,
            height: 40,
            point: LatLng(latitude, longitude),
            child: GestureDetector(
              onTap: () => _showInfoDialog(data),
              child: const Icon(Icons.local_hospital,
                  color: Colors.green, size: 35),
            ),
          );
        }).toList();

        if (context.mounted) {
          setState(() {
            markers = [...alertMarkers, ...campMarkers];
          });
        }
      });
    });
  }

  @override
  void dispose() {
    firebaseSubscription.cancel();
    super.dispose();
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

  void _showInfoDialog(Map<String, dynamic> alert) {
    showDialog(
        context: context,
        builder: (_) {
          DateTime timestamp = (alert['timestamp'] as Timestamp).toDate();
          var replies = alert.containsKey('replies') ? alert['replies'] : [];
          double screenWidth = MediaQuery.of(context).size.width;
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${alert['name']}(${alert['userType']})',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                      )
                    ],
                  ),
                  Text(
                    alert['comment'],
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy hh:mm a').format(timestamp),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  if (replies.isNotEmpty)
                    const Text(
                      'Replies:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ...replies.map((c) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${c['userName']}(${c['userType']})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(DateTime.parse(c['time'])),
                                      textAlign: TextAlign.right,
                                    ),
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(DateTime.parse(c['time'])),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(c['reply'] ?? ''),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        });
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
                maxZoom: 23,
                minZoom: 1,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapUrlTemplate,
                  subdomains: ['0', '1', '2', '3'],
                  // subdomains: ['a', 'b', 'c'],
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
