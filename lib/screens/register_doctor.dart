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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String selectedGender = 'Male';
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController workingStatusController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> registerDoctor() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'gender': selectedGender,
        'qualification': qualificationController.text.trim(),
        'workingStatus': workingStatusController.text.trim(),
        'experience': experienceController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'doctorId': doctorIdController.text.trim(),
        'userType': 'doctor',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor registered successfully!')),
      );

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Doctor Registration",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildInputField(label: "Name", controller: nameController),
            buildInputField(
                label: "Age",
                controller: ageController,
                inputType: TextInputType.number),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedGender = value!);
                },
              ),
            ),
            buildInputField(
                label: "Qualification", controller: qualificationController),
            buildInputField(
                label: "Working Status", controller: workingStatusController),
            buildInputField(
                label: "Experience (in years)",
                controller: experienceController,
                inputType: TextInputType.number),
            buildInputField(
                label: "Email",
                controller: emailController,
                inputType: TextInputType.emailAddress),
            buildInputField(
                label: "Phone Number",
                controller: phoneController,
                inputType: TextInputType.phone),
            buildInputField(label: "Doctor ID", controller: doctorIdController),
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
              controller: confirmPasswordController,
              obscureText: !isPasswordVisible,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    onPressed: registerDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
