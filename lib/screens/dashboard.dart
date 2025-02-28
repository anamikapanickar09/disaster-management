import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Doctor Dashboard")), body: Center(child: Text("Welcome, Doctor!")));
  }
}

class VictimDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Victim Dashboard")), body: Center(child: Text("Welcome, Victim!")));
  }
}

class VolunteerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Volunteer Dashboard")), body: Center(child: Text("Welcome, Volunteer!")));
  }
}
