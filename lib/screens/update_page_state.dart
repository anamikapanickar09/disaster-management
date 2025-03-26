import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Alerts & Camps'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Alerts'),
              Tab(text: 'Camps'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UpdateAlerts(),
            UpdateCamps(),
          ],
        ),
      ),
    );
  }
}

class UpdateAlerts extends StatefulWidget {
  const UpdateAlerts({super.key});

  @override
  _UpdateAlertsState createState() => _UpdateAlertsState();
}

class _UpdateAlertsState extends State<UpdateAlerts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> getCurrentUserDetails() async {
    var userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    return {
      'userType': userDoc['userType']?.toString() ?? 'Unknown',
      'name': userDoc['name'] ?? 'Anonymous',
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('alerts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var alerts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            var alert = alerts[index];
            var comments = [];

            if (alert['comment'] is List) {
              comments = alert['comment'] as List<dynamic>;
            } else if (alert['comment'] is String) {
              comments = [
                {
                  'userType': alert['userType'] ?? 'Unknown',
                  'userName': alert['name'] ?? 'Anonymous',
                  'time': '',
                  'latitude': alert['latitude'],
                  'longitude': alert['longitude'],
                  'comment': alert['comment'],
                }
              ];
            }

            TextEditingController commentController = TextEditingController();

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: ${alert['latitude']}'),
                    Text('Longitude: ${alert['longitude']}'),
                    Text('User Type: ${alert['userType']}'),
                    Text('Name: ${alert['name']}'),
                    const SizedBox(height: 10),
                    const Text('Comments:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    if (comments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${comments[0]['userType']}: ${comments[0]['userName']}'),
                            Text('Time: ${comments[0]['time']}'),
                            Text('Latitude: ${comments[0]['latitude']}'),
                            Text('Longitude: ${comments[0]['longitude']}'),
                            const SizedBox(height: 4),
                            Text(comments[0]['comment'] ?? ''),
                          ],
                        ),
                      ),
                    ...comments.skip(1).map((c) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c['userType']}: ${c['userName']}'),
                              Text('Time: ${c['time']}'),
                              Text('Latitude: ${c['latitude']}'),
                              Text('Longitude: ${c['longitude']}'),
                              const SizedBox(height: 4),
                              Text(c['comment'] ?? ''),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      decoration:
                          const InputDecoration(labelText: 'Add a comment'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var userDetails = await getCurrentUserDetails();
                            String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now());
                            var newComment = {
                              'userType': userDetails['userType'],
                              'userName': userDetails['name'],
                              'time': timestamp,
                              'latitude': alert['latitude'],
                              'longitude': alert['longitude'],
                              'comment': commentController.text,
                            };
                            await _firestore
                                .collection('alerts')
                                .doc(alert.id)
                                .update({
                              'comment': FieldValue.arrayUnion([newComment]),
                            });
                            commentController.clear();
                          },
                          child: const Text('Add Comment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class UpdateCamps extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UpdateCamps({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('camps').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var camps = snapshot.data!.docs;

        return ListView.builder(
          itemCount: camps.length,
          itemBuilder: (context, index) {
            var camp = camps[index];
            TextEditingController latitudeController =
                TextEditingController(text: camp['latitude'].toString());
            TextEditingController longitudeController =
                TextEditingController(text: camp['longitude'].toString());
            TextEditingController typeController =
                TextEditingController(text: camp['userType']);
            TextEditingController nameController =
                TextEditingController(text: camp['name']);

            return Card(
