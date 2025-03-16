import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Import the generated Firebase options
import 'screens/login_page.dart';
import 'screens/victim_home_page.dart';
import 'screens/doctor_home_page.dart';
import 'screens/volunteer_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Set Firebase options for web
  );

  User? user = FirebaseAuth.instance.currentUser;

  Widget homePage;
  if (user != null) {
    // Fetch user type from Firestore
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String userType = userDoc['userType'];

    if (userType == 'doctor') {
      homePage = const DoctorHomePage();
    } else if (userType == 'victim') {
      homePage = const VictimHomePage();
    } else if (userType == 'volunteer') {
      homePage = const VolunteerHomePage();
    } else {
      homePage = const LoginPage();
    }
  } else {
    homePage = const LoginPage();
  }

  runApp(MyApp(homePage: homePage));
}

class MyApp extends StatelessWidget {
  final Widget homePage;
  const MyApp({super.key, required this.homePage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage,
    );
  }
}
