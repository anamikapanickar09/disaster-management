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
          title: Text('Update Alerts & Camps'),
          bottom: TabBar(
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

class UpdateAlerts extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UpdateAlerts({super.key});

  Future<Map<String, String>> getCurrentUserDetails() async {
    var userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    return {
      'userType': userDoc['userType'] ?? 'Unknown',
      'name': userDoc['name'] ?? 'Anonymous',
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('alerts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var alerts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            var alert = alerts[index];
            var comments = alert['comment'];
            if (comments is String) {
              comments = [comments];
            } else if (comments == null) {
              comments = [];
            }
            TextEditingController commentController = TextEditingController();

            return Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: ${alert['latitude']}'),
                    Text('Longitude: ${alert['longitude']}'),
                    Text('User Type: ${alert['userType']}'),
                    Text('Name: ${alert['name']}'),
                    SizedBox(height: 10),
                    Text('Comments:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...comments.map((c) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${c['userType']} - ${c['userName']} - ${c['time']}'),
                            Text(c['comment']),
                            SizedBox(height: 10),
                          ],
                        )),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(labelText: 'Add a comment'),
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
                              'comment': commentController.text,
                            };
                            await _firestore
                                .collection('alerts')
                                .doc(alert.id)
                                .update({
                              'comments': FieldValue.arrayUnion([newComment]),
                            });
                            commentController.clear();
                          },
                          child: Text('Add Comment'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _firestore
                                .collection('alerts')
                                .doc(alert.id)
                                .delete();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Delete'),
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
          return Center(child: CircularProgressIndicator());
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
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        controller: latitudeController,
                        decoration: InputDecoration(labelText: 'Latitude')),
                    TextField(
                        controller: longitudeController,
                        decoration: InputDecoration(labelText: 'Longitude')),
                    TextField(
                        controller: typeController,
                        decoration: InputDecoration(labelText: 'User Type')),
                    TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _firestore
                                .collection('camps')
                                .doc(camp.id)
                                .update({
                              'latitude': double.parse(latitudeController.text),
                              'longitude':
                                  double.parse(longitudeController.text),
                              'userType': typeController.text,
                              'name': nameController.text,
                            });
                          },
                          child: Text('Update'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _firestore
                                .collection('camps')
                                .doc(camp.id)
                                .delete();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Delete'),
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
