import 'package:flutter/material.dart';

class VictimScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Victim Module')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Report incidents and request help here.', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality to report an emergency
              },
              child: Text('Report an Emergency'),
            ),
          ],
        ),
      ),
    );
  }
}
