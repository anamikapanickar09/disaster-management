import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterVolunteer extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController volunteerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterVolunteer({super.key});

  void _register(BuildContext context) {
    // Add your registration logic
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volunteer Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name")),
            TextField(
                controller: volunteerIdController,
                decoration: InputDecoration(labelText: "Volunteer ID")),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _register(context), child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
