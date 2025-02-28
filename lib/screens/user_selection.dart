import 'package:flutter/material.dart';
import 'register_doctor.dart';
import 'register_victim.dart';
import 'register_volunteer.dart';

class UserSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select User Type")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterDoctor()));
              },
              child: Text("Register as Doctor"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterVictim()));
              },
              child: Text("Register as Victim"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterVolunteer()));
              },
              child: Text("Register as Volunteer"),
            ),
          ],
        ),
      ),
    );
  }
}
