import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notifications = [
      "Flood warning in your area.",
      "Emergency medical camp set up nearby.",
      "Severe weather expected tomorrow.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading:
                  Icon(Icons.notification_important, color: Colors.deepPurple),
              title: Text(notifications[index]),
            ),
          );
        },
      ),
    );
  }
}
