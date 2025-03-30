import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'notification_page.dart';
import 'login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'update_page_state.dart';
import 'add_camp_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // bool _isBlinking = true;

  // @override
  // void initState() {
  //   super.initState();
  //   Timer.periodic(const Duration(milliseconds: 500), (timer) {
  //     if (!mounted) return;
  //     setState(() {
  //       _isBlinking = !_isBlinking;
  //     });
  //   });
  // }

  Future<void> sendEmergencyAlert(String comment) async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        // print("❌ No user logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in!')),
        );
        return;
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // print("❌ User details not found.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User details not found!')),
          );
        }
        return;
      }

      Map<String, dynamic> userDetails = userDoc.data() as Map<String, dynamic>;

      String name = userDetails['name'] ?? 'Unknown';
      String userType = userDetails['userType'] ?? 'Unknown';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // print("❌ Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // print("❌ Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance.collection('alerts').add({
        'name': name,
        'userType': userType,
        'comment': comment,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'closed': false,
        'committed': false,
      });

      // print("✅ Emergency alert sent successfully.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency alert sent!')),
        );
      }
    } catch (e) {
      // print("❌ Error sending emergency alert: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending alert: $e')),
        );
      }
    }
  }

  void _showEmergencyAlert(BuildContext context) {
    bool isLoading = false;
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Emergency Alert",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLoading)
                  const Text(
                    "Send an emergency alert to other users.",
                    style: TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 10),
                if (!isLoading)
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      labelText: "Emergency Comments",
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              if (!isLoading)
                TextButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      setState(() => isLoading = true);
                      await sendEmergencyAlert(commentController.text);
                      if (context.mounted) Navigator.pop(context);
                      setState(() => isLoading = false);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black26,
                  ),
                  child: Text(
                    "Send Alert",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Admin",
          style: TextStyle(
            color: Color.fromRGBO(76, 175, 80, 1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox(),
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
          IconButton(
            icon:
                const Icon(Icons.logout, color: Color.fromRGBO(76, 175, 80, 1)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
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
                title: "Add Camp Details",
                icon: Icons.local_hospital,
                iconColor: const Color.fromRGBO(76, 175, 80, 1),
                textColor: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCampPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFeatureBox(
                title: "Alerts & Camps",
                icon: Icons.edit,
                iconColor: Colors.orange,
                textColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdatePage()),
                  );
                },
              ),
            ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsBox(BuildContext context) {
    final Map<String, Map<String, dynamic>> emergencyContacts = {
      'Police': {'number': '100', 'color': Colors.red},
      'Ambulance': {'number': '102', 'color': Colors.blue},
      'Fire': {'number': '101', 'color': Colors.orange},
      'Volunteer': {'number': '+918547243687', 'color': Colors.green}
    };

    Future<void> makeCall(String number) async {
      final Uri callUri = Uri(scheme: 'tel', path: number);
      if (await launchUrl(callUri)) {
        // print('✅ Calling $number');
        return;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch call')),
          );
        }
      }
    }

    void showCallDialog(String name, String number) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Call $name?'),
            content: Text('Do you want to make a call to $number?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  makeCall(number);
                },
                child: const Text('Call'),
              ),
            ],
          );
        },
      );
    }

    double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Emergency Contacts",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...emergencyContacts.entries.map((entry) {
                  return GestureDetector(
                    onTap: () =>
                        showCallDialog(entry.key, entry.value['number']),
                    child: Container(
                      width: deviceWidth / 4 - 25,
                      height: deviceWidth / 4 - 25,
                      decoration: BoxDecoration(
                        color: entry.value['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.white, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
