import 'package:disaster/screens/register_doctor.dart';
import 'package:disaster/screens/register_volunteer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterVictim extends StatefulWidget {
  const RegisterVictim({super.key});

  @override
  State<RegisterVictim> createState() => _RegisterVictimState();
}

class _RegisterVictimState extends State<RegisterVictim> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();

  bool isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  void _register() async {
    String email = emailController.text.trim();
    String emergencyContact = emergencyContactController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || emergencyContact.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text,
        'email': email,
        'emergencyContact': emergencyContact,
        'userType': 'victim',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.message}"),
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    emergencyContactController.dispose();
    passwordController.dispose();
    super.dispose();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "User Registration",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
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
            icon: Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildInputField(label: "Name", controller: nameController),
            buildInputField(label: "Email", controller: emailController),
            buildInputField(
                label: "Emergency Contact",
                controller: emergencyContactController),
            buildInputField(
              label: "Password",
              controller: passwordController,
              obscureText: !isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                },
              ),
            ),
            buildInputField(
              label: "Confirm Password",
              controller: passwordCheckController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
