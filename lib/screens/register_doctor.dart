import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterDoctor extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterDoctor({super.key});

  void _register(BuildContext context) {
    // Add your registration logic
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                controller: nameController,
                decoration: InputDecoration(labelText: "Name")),
            TextField(
                controller: doctorIdController,
                decoration: InputDecoration(labelText: "Doctor ID")),
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
