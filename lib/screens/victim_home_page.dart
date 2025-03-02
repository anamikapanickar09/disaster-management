import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'map_page.dart';
import 'notification_page.dart';

class VictimHomePage extends StatefulWidget {
  const VictimHomePage({super.key});

  @override
  _VictimHomePageState createState() => _VictimHomePageState();
}

class _VictimHomePageState extends State<VictimHomePage> {
  bool _isBlinking = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  Future<void> sendEmergencyAlert(String comment) async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission != PermissionStatus.granted) return;

    var currentLocation = await location.getLocation();

    await FirebaseFirestore.instance.collection('alerts').add({
      'comment': comment,
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showEmergencyAlert(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emergency Alert"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send an emergency alert to other users."),
              SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "Emergency Comments",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  await sendEmergencyAlert(commentController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Send Alert"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster Response"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildFeatureBox(
            title: "Map View",
            icon: Icons.map,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
          ),
          SizedBox(height: 16),
          _buildFeatureBox(
            title: "Alert",
            icon: Icons.warning,
            color: _isBlinking ? Colors.red : Colors.red.withOpacity(0.4),
            onTap: () => _showEmergencyAlert(context),
          ),
          SizedBox(height: 16),
          _buildFeatureBox(
            title: "GPT Help",
            icon: Icons.help,
            color: Colors.green,
            onTap: () {},
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Emergency Contacts",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                _contactRow("Fire Department", "101"),
                _contactRow("Ambulance", "102"),
                _contactRow("Police", "100"),
                _contactRow("Disaster Helpline", "108"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(String title, String number) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12)),
          Text(number,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
