import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterVictim extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register(BuildContext context) {
    // Add your registration logic
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Victim Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emergencyContactController, decoration: InputDecoration(labelText: "Emergency Contact")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => _register(context), child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
