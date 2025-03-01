import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map View")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(10.0, 76.0), // Use initialCenter instead of center
          initialZoom: 10.0, // Use initialZoom instead of zoom
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            tileProvider:
                CancellableNetworkTileProvider(), // Improved performance),
          ),
        ],
      ),
    );
  }
}
