import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Doctor Dashboard")),
        body: Center(child: Text("Welcome, Doctor!")));
  }
}

class VictimDashboard extends StatelessWidget {
  const VictimDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Victim Dashboard")),
        body: Center(child: Text("Welcome, Victim!")));
  }
}

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Volunteer Dashboard")),
        body: Center(child: Text("Welcome, Volunteer!")));
  }
}
