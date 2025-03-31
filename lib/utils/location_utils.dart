import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

double calculateDistance(LatLng p1, LatLng p2) {
  const R = 6371; // Radius of Earth in km
  double dLat = (p2.latitude - p1.latitude) * (pi / 180);
  double dLon = (p2.longitude - p1.longitude) * (pi / 180);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(p1.latitude * pi / 180) *
          cos(p2.latitude * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}

Map<LatLng, int> getClusterCounts(List<LatLng> markers) {
  Map<LatLng, int> clusterCounts = {};

  for (var point in markers) {
    bool foundCluster = false;
    for (var cluster in clusterCounts.keys) {
      if (calculateDistance(cluster, point) <= 1) {
        clusterCounts[cluster] = clusterCounts[cluster]! + 1;
        foundCluster = true;
        break;
      }
    }
    if (!foundCluster) {
      clusterCounts[point] = 1;
    }
  }

  return clusterCounts;
}

Future<List<LatLng>> getAlertLocations() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('alerts')
      .where('closed', isEqualTo: false)
      .get();
  List<LatLng> locations = [];

  for (var doc in snapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    locations.add(LatLng(data['latitude'], data['longitude']));
  }

  return locations;
}

List<LatLng> generateCircle(LatLng center, double radius) {
  List<LatLng> points = [];
  for (int i = 0; i < 360; i += 10) {
    double angle = i * pi / 180;
    double dx = radius * cos(angle) / 111.32; // Approximate degree distance
    double dy =
        radius * sin(angle) / (111.32 * cos(center.latitude * pi / 180));
    points.add(LatLng(center.latitude + dx, center.longitude + dy));
  }
  return points;
}
