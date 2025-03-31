import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  // Function to launch URLs (for phone calls or websites)
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title and description section
              // Text(
              //   'About This App',
              //   style: TextStyle(
              //     fontSize: 24.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              SizedBox(height: 10.0),
              Text(
                'This app is designed to connect individuals in crisis with immediate assistance from local emergency services, including police, doctors, and volunteers. Whether you are experiencing a medical emergency or need urgent help, we provide direct access to the necessary resources.',
                style: TextStyle(fontSize: 16.0,  ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20.0),
              
              // Emergency Contact Buttons
              // Text(
              //   'Quick Access to Emergency Services',
              //   style: TextStyle(
              //     fontSize: 20.0,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.blueAccent,
              //   ),
              // ),
              // SizedBox(height: 15.0),
          
              // // Police Button
              // ElevatedButton(
              //   onPressed: () => _launchURL('tel:+1122334455'), // Replace with your local police emergency number
              //   child: Text('Contact Police'),
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 15.0),
              //     textStyle: TextStyle(fontSize: 18.0),
              //   ),
              // ),
              // SizedBox(height: 10.0),
          
              // // Doctors Button
              // ElevatedButton(
              //   onPressed: () => _launchURL('tel:+1234567890'), // Replace with local emergency doctor number
              //   child: Text('Contact Doctor'),
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 15.0),
              //     textStyle: TextStyle(fontSize: 18.0),
              //   ),
              // ),
              // SizedBox(height: 10.0),
          
              // // Volunteers Button
              // ElevatedButton(
              //   onPressed: () => _launchURL('tel:+1987654321'), // Replace with local volunteer emergency number
              //   child: Text('Contact Volunteer'),
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 15.0),
              //     textStyle: TextStyle(fontSize: 18.0),
              //   ),
              // ),
              // SizedBox(height: 20.0),
          
              // // Additional Resources section
              // Text(
              //   'Additional Resources',
              //   style: TextStyle(
              //     fontSize: 20.0,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.blueAccent,
              //   ),
              // ),
              // SizedBox(height: 10.0),
              Text(
                'Made by CrisisConnect Team - CS AI',
                style: TextStyle(fontSize: 16.0,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
