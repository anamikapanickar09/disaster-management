import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCampPage extends StatefulWidget {
  const AddCampPage({super.key});

  @override
  _AddCampPageState createState() => _AddCampPageState();
}

class _AddCampPageState extends State<AddCampPage> {
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  Future<Map<String, dynamic>> fetchUserDetails() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) throw "User not logged in.";

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userSnapshot.exists) throw "User details not found.";

    return userSnapshot.data() as Map<String, dynamic>;
  }

  Future<void> _submitCampDetails() async {
    setState(() => _isSubmitting = true);

    try {
      // Get user details
      Map<String, dynamic> userDetails = await fetchUserDetails();
      String name = userDetails['name'] ?? 'Unknown';
      String userType = userDetails['userType'] ?? 'Unknown';

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw "Location permission denied.";
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw "Location permissions are permanently denied.";
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Store data in Firebase
      await FirebaseFirestore.instance.collection('camps').add({
        'name': name,
        'userType': userType,
        'comment': _detailsController.text,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'is_open': true,
      });

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Camp details added!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Camp Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Enter details about the camp location.",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: "Camp Details",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCampDetails,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
