import 'package:flutter/material.dart';
import 'user_selection.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Dummy login validation
    if (username == "doctor") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DoctorDashboard()));
    } else if (username == "victim") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VictimDashboard()));
    } else if (username == "volunteer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VolunteerDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserSelectionPage()));
              },
              child: Text("New User? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
