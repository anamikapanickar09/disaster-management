import 'package:flutter/material.dart';
import 'doctor_screen.dart'; // Import Doctor screen
import 'victim_screen.dart'; // Import Victim screen

class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Module')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Assist in rescue and relief operations.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality to view volunteer tasks
              },
              child: Text('View Volunteer Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
