import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewUpdatesPage extends StatelessWidget {
  const ViewUpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            // color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('public_updates')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List notifications = snapshot.data!.docs;
          // notifications.sort((a, b) => (b['timestamp'] as Timestamp)
          //     .compareTo((a['timestamp'] as Timestamp)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              String userType = notification.get("userType");
              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.notifications_active,
                      color: Colors.deepPurple, size: 30),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.get("update"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                      // Expanded(
                      //   child: Text(
                      //     "${(notification.get("latitude") as double).toStringAsFixed(6)}, ${(notification.get("longitude") as double).toStringAsFixed(6)}",
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 14,
                      //     ),
                      //     softWrap: true,
                      //     textAlign: TextAlign
                      //         .right, // Align to the right for readability
                      //   ),
                      // ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(userType[0].toUpperCase() + userType.substring(1))}: ${notification.get("name")}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat("dd MMM yyyy hh:mm a").format(
                            (notification.get("timestamp") as Timestamp)
                                .toDate()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
