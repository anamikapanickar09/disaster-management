import 'package:flutter/material.dart';
import 'victim_screen.dart';
import 'doctor_screen.dart';
import 'volunteer_screen.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Disaster Management System')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Victim Module',
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => VictimScreen())),
            ),
            CustomButton(
              text: 'Doctor Module',
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => DoctorScreen())),
            ),
            CustomButton(
              text: 'Volunteer Module',
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => VolunteerScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
