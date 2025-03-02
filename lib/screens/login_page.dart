import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // To access Firestore for user type
import 'package:flutter/material.dart';
import 'register_doctor.dart';
import 'register_victim.dart';
import 'register_volunteer.dart';
import 'victim_home_page.dart'; // Import Victim screen
import 'doctor_home_page.dart'; // Import Doctor screen
import 'volunteer_screen.dart'; // Import Volunteer screen

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
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Sign in with email and password using Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username, // Here, using username as email for simplicity
        password: password,
      );

      // Fetch the user type from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Assuming 'users' is the collection
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String userType =
            userDoc['userType']; // Assuming 'userType' field exists

        // Redirect based on user type
        if (userType == 'doctor') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DoctorHomePage()));
        } else if (userType == 'victim') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const VictimHomePage()));
        } else if (userType == 'volunteer') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const VolunteerScreen()));
        }
      } else {
        throw 'User type not found in database';
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
      backgroundColor: Colors.deepPurple,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width - 150, 100, 20, 0),
                    items: [
                      PopupMenuItem(
                        value: 'Doctor',
                        child: Text("Register as Doctor"),
                      ),
                      PopupMenuItem(
                        value: 'Volunteer',
                        child: Text("Register as Volunteer"),
                      ),
                    ],
                  ).then((value) {
                    if (value != null) _navigateToRegistration(value);
                  });
                },
                child: Text("Other User Type",
                    style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: "Username (Email)",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "LOGIN",
                        style:
                            TextStyle(color: Colors.deepPurple, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterVictim()));
                        },
                        child: Text("Sign Up",
                            style: TextStyle(color: Colors.white)),
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
