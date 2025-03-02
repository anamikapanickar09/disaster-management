import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'notification_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool _isBlinking = true;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  Future<void> sendEmergencyAlert(String comment) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("❌ Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("❌ Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance.collection('alerts').add({
        'comment': comment,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Emergency alert sent successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency alert sent!')),
      );
    } catch (e) {
      print("❌ Error sending emergency alert: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending alert: $e')),
      );
    }
  }

  void _showEmergencyAlert(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Emergency Alert"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Send an emergency alert to other users."),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
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
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  await sendEmergencyAlert(commentController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Send Alert"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateAlerts(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nearby Alerts"),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('alerts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var alerts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    var alert = alerts[index];
                    return ListTile(
                      title: Text(alert['comment']),
                      subtitle: Text(
                          "Lat: ${alert['latitude']}, Lng: ${alert['longitude']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                        onPressed: () {
                          _showEditAlertDialog(
                              context, alert.id, alert['comment']);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAlertDialog(
      BuildContext context, String alertId, String oldComment) {
    TextEditingController editController =
        TextEditingController(text: oldComment);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Alert"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: "Updated Comment",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('alerts')
                    .doc(alertId)
                    .update({'comment': editController.text});
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _buildFeatureBox(
                title: "Map View",
                icon: Icons.map,
                iconColor: Colors.blue,
                textColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFeatureBox(
                title: "Alert",
                icon: Icons.warning,
                iconColor: _isBlinking ? Colors.red : Colors.transparent,
                textColor: Colors.red,
                onTap: () => _showEmergencyAlert(context),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFeatureBox(
                title: "Update Alerts",
                icon: Icons.edit,
                iconColor: Colors.orange,
                textColor: Colors.orange,
                onTap: () => _showUpdateAlerts(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildEmergencyContactsBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBox({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.green, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "Police: 100\nAmbulance: 102\nFire Brigade: 101",
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
