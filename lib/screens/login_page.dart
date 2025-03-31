import 'package:disaster/screens/admin_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'register_doctor.dart';
import 'register_victim.dart';
import 'register_volunteer.dart';
import 'victim_home_page.dart';
import 'doctor_home_page.dart';
import 'volunteer_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    // var users =
    //     (await FirebaseFirestore.instance.collection("users").get()).docs;

    // for (var user in users) {
    //   // await FirebaseFirestore.instance
    //   //     .collection("users")
    //   //     .doc(user.id)
    //   //     .delete();
    //   _auth.
    // }
    // try {
    //   UserCredential userCredential =
    //       await _auth.createUserWithEmailAndPassword(
    //     email: "admin@gmail.com",
    //     password: "admin123",
    //   );
    // } catch (e) {
    //   print(e);
    // }
    // return;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String userType = userDoc['userType'];

        if (userType == 'doctor') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DoctorHomePage()));
          FirebaseMessaging.instance.subscribeToTopic("doctor");
        } else if (userType == 'victim') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const VictimHomePage()));
          FirebaseMessaging.instance.subscribeToTopic("updates");
        } else if (userType == 'volunteer') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const VolunteerHomePage()));
          FirebaseMessaging.instance.subscribeToTopic("volunteer");
        } else if (userType == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()));
        }
      } else {
        throw 'User type not found in database';
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRegistration(String userType) {
    if (userType == 'Doctor') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterDoctor()));
    } else if (userType == 'Volunteer') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RegisterVolunteer()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              // decoration: BoxDecoration(
              //   color: Colors.grey[900],
              //   borderRadius: BorderRadius.circular(20),
              // ),
              child: ElevatedButton(
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width - 150, 100, 20, 0),
                    items: [
                      PopupMenuItem(
                        value: 'Doctor',
                        child: Text(
                          "Register as Doctor",
                          // style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Volunteer',
                        child: Text(
                          "Register as Volunteer",
                          // style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    // color: Colors.grey[900], // Dark background for the popup
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    // ),
                  ).then((value) {
                    if (value != null) _navigateToRegistration(value);
                  });
                },
                child: const Text(
                  "Other User Type",
                  // style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      hintText: "Username (Email)",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(30),
                        // ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        // style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterVictim()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.indigo[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
