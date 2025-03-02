import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class RegisterDoctor extends StatefulWidget {
  const RegisterDoctor({super.key});

  @override
  _RegisterDoctorState createState() => _RegisterDoctorState();
}

class _RegisterDoctorState extends State<RegisterDoctor> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerDoctor() async {
    setState(() => isLoading = true);

    try {
      // Register the doctor securely with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Store additional profile info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'doctorId': doctorIdController.text.trim(),
        'userType': 'doctor',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor registered successfully!')),
      );

      // Go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: doctorIdController,
              decoration: InputDecoration(labelText: "Doctor ID"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerDoctor,
                    child: Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
