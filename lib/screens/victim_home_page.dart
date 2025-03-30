import 'dart:async';
import 'package:disaster/screens/app_drawer.dart';
import 'package:disaster/screens/send_public_updates.dart';
import 'package:disaster/screens/view_updates_page.dart';
import 'package:disaster/services/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'notification_page.dart';
import 'login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'update_page_state.dart';
// import 'add_camp_page.dart';

class VictimHomePage extends StatefulWidget {
  const VictimHomePage({super.key});

  @override
  State<VictimHomePage> createState() => _VictimHomePageState();
}

class _VictimHomePageState extends State<VictimHomePage> {
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

  Future<void> sendPublicUpdates(String update) async {
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

      await FirebaseFirestore.instance.collection('public_updates').add({
        'name': name,
        'userType': userType,
        'update': update,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // print("✅ Emergency alert sent successfully.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Public update sent!')),
        );
      }
    } catch (e) {
      // print("❌ Error sending emergency alert: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending public update: $e')),
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

  void _showSendUpdates(BuildContext context) {
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
              "Send Public Updates",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLoading)
                  const Text(
                    "Send necessary updates to the public.",
                    style: TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 10),
                if (!isLoading)
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      labelText: "Type infos here",
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
                    child: CircularProgressIndicator(),
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
                      await sendPublicUpdates(commentController.text);
                      if (context.mounted) Navigator.pop(context);
                      setState(() => isLoading = false);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black26,
                  ),
                  child: Text(
                    "Send Update",
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
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  foregroundImage: AssetImage("assets/logo.png"),
                  backgroundColor: Colors.transparent,
                  radius: 18,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Crisis Connect",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Hamburger Icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens drawer
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewUpdatesPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stack(
            //   clipBehavior: Clip.none, // ✅ Allows overflow
            //   children: [
            //     Container(color: Colors.white), // Main content
            //     Positioned(
            //       top: -10, // Moves widget up into AppBar
            //       left: 110,
            //       right: 20,
            //       child: Text(
            //         "HOPE IN CRISIS, HELP AT HAND",
            //         style: TextStyle(fontSize: 15),
            //       ),
            //     ),
            //   ],
            // ),
            Text(
              "HOPE IN CRISIS, HELP AT HAND",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 20,
            ),
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
                iconColor: Colors.red,
                // iconColor: _isBlinking ? Colors.red : Colors.transparent,
                textColor: Colors.red,
                onTap: () => _showEmergencyAlert(context),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFeatureBox(
                  title: "AI Help",
                  icon: Icons.help,
                  iconColor: const Color.fromRGBO(76, 175, 80, 1),
                  textColor: Colors.green,
                  // onTap: () => showPopUp(context,
                  //     function: () {},
                  //     popUpContent: Text(
                  //       "Work under progress",
                  //       style: TextStyle(fontSize: 20),
                  //     ),
                  //     dismissible: true),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "AI is future. This is present.\n Yesterday is history, Tomrrow is mystery, and today is a gift. Thats why we call it a present. bye")));
                  }),
            ),
            const SizedBox(height: 20),
            _buildEmergencyContactsBox(context),
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
      'Helpline': {'number': '+918547243687', 'color': Colors.green}
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
