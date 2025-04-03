import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/pop_up.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
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
  State<UpdateAlerts> createState() => _UpdateAlertsState();
}

class _UpdateAlertsState extends State<UpdateAlerts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> getCurrentUserDetails() async {
    var userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    return {
      'userType': userDoc['userType']?.toString() ?? 'Unknown',
      'name': userDoc.get('name') ?? 'Anonymous',
    };
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: _firestore.collection('alerts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var rawAlerts = snapshot.data!.docs;
        rawAlerts.sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo((a['timestamp'] as Timestamp)));
        rawAlerts = rawAlerts.where((i) => !i['closed']).toList();

        List<dynamic> committedCases = [];
        List<dynamic> notCommittedCases = [];
        for (var alert in rawAlerts) {
          (alert['committed'] ? committedCases : notCommittedCases).add(alert);
        }
        List alerts = [];
        alerts.addAll(notCommittedCases);
        alerts.addAll(committedCases);

        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            var alert = alerts[index];
            DateTime timestamp = (alert['timestamp'] as Timestamp).toDate();
            var replies =
                (alert.data() as Map<String, dynamic>).containsKey('replies')
                    ? alert['replies'] as List<dynamic>
                    : [];
            replies.sort((a, b) {
              return DateTime.parse(b['time'])
                  .compareTo(DateTime.parse(a['time']));
            });

            TextEditingController commentController = TextEditingController();

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.9 - 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${(alert['userType'][0].toUpperCase() + alert['userType'].substring(1))}: ${alert['name']}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text(
                              //     "${alert['latitude']}, ${alert['longitude']}"),
                              FutureBuilder<String>(
                                future: getPlaceFromCoordinates(alert['latitude'], alert['longitude']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text('Loading place...');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    return Text(snapshot.data!); // !.split(', ').join(',\n'));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(timestamp),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              DateFormat('hh:mm a').format(timestamp),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      alert['comment'],
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (replies.isNotEmpty)
                      const Text(
                        'Replies:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ...replies.map((c) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          width: screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${(c['userType'][0].toUpperCase() + c['userType'].substring(1))}: ${c['userName']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(DateTime.parse(c['time'])),
                                        textAlign: TextAlign.right,
                                      ),
                                      Text(
                                        DateFormat('hh:mm a')
                                            .format(DateTime.parse(c['time'])),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c['reply'] ?? ''),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: 'Reply',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            var userDetails = await getCurrentUserDetails();
                            String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now());
                            var newComment = {
                              'userType': userDetails['userType'],
                              'userName': userDetails['name'],
                              'time': timestamp,
                              'reply': commentController.text,
                            };
                            await _firestore
                                .collection('alerts')
                                .doc(alert.id)
                                .update({
                              'replies': FieldValue.arrayUnion([newComment]),
                            });
                            commentController.clear();
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: alert['committed']
                              ? null
                              : () {
                                  showPopUp(context,
                                      popUpTitle: Text('Commit Case'),
                                      popUpContent: Text(
                                          'Are you sure you want to commit the case?'),
                                      function: () async {
                                    await _firestore
                                        .collection('alerts')
                                        .doc(alert.id)
                                        .update({
                                      'committed': true,
                                    });
                                  });
                                },
                          child: SizedBox(
                              width: screenWidth * 0.28,
                              child: Center(child: Text('Commit Case'))),
                        ),
                        ElevatedButton(
                          onPressed: alert['closed']
                              ? null
                              : () {
                                  showPopUp(
                                    context,
                                    popUpTitle: Text('Close Case'),
                                    popUpContent: Text(
                                        'Are you sure you want to close the case?'),
                                    function: () async {
                                      await _firestore
                                          .collection('alerts')
                                          .doc(alert.id)
                                          .update({
                                        'closed': true,
                                      });
                                    },
                                  );
                                },
                          child: SizedBox(
                            width: screenWidth * 0.28,
                            child: Center(child: Text('Close Case')),
                          ),
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
  UpdateCamps({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> getCurrentUserDetails() async {
    var userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    return {
      'userType': userDoc['userType']?.toString() ?? 'Unknown',
      'name': userDoc.get('name') ?? 'Anonymous',
    };
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: _firestore.collection('camps').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var camps = snapshot.data!.docs;
        // camps.sort((a, b) => (b['timestamp'] as Timestamp)
        //     .compareTo((a['timestamp'] as Timestamp)));

        return ListView.builder(
          itemCount: camps.length,
          itemBuilder: (context, index) {
            var camp = camps[index];
            // DateTime timestamp = (camp['timestamp'] as Timestamp).toDate();
            var replies =
                (camp.data() as Map<String, dynamic>).containsKey('replies')
                    ? camp['replies'] as List<dynamic>
                    : [];
            replies.sort((a, b) {
              return DateTime.parse(b['time'])
                  .compareTo(DateTime.parse(a['time']));
            });

            TextEditingController commentController = TextEditingController();

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.9 - 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${camp['name']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text("${camp['latitude']}, ${camp['longitude']}"),
                              FutureBuilder<String>(
                                future: getPlaceFromCoordinates(camp['latitude'], camp['longitude']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text('Loading place...');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    return Text(snapshot.data!); // !.split(', ').join(',\n'));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      camp['status'],
                      style: TextStyle(
                          fontSize: 18,
                          color: camp['status'] == "open"
                              ? Colors.green
                              : Colors.red),
                    ),
                    const SizedBox(height: 10),
                    if (replies.isNotEmpty)
                      const Text(
                        'Replies:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ...replies.map((c) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          width: screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${(c['userType'][0].toUpperCase() + c['userType'].substring(1))}: ${c['userName']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(DateTime.parse(c['time'])),
                                        textAlign: TextAlign.right,
                                      ),
                                      Text(
                                        DateFormat('hh:mm a')
                                            .format(DateTime.parse(c['time'])),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c['reply'] ?? ''),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: 'Reply',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            var userDetails = await getCurrentUserDetails();
                            String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now());
                            var newComment = {
                              'userType': userDetails['userType'],
                              'userName': userDetails['name'],
                              'time': timestamp,
                              'reply': commentController.text,
                            };
                            await _firestore
                                .collection('camps')
                                .doc(camp.id)
                                .update({
                              'replies': FieldValue.arrayUnion([newComment]),
                            });
                            commentController.clear();
                          },
                        ),
                      ),
                    ),
                    //     if(camp['status'] == "open") Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         ElevatedButton(
                    //           onPressed: camp['closed']
                    //               ? null
                    //               : () {
                    //                   showPopUp(
                    //                     context,
                    //                     popUpTitle: Text('Close Case'),
                    //                     popUpContent: Text(
                    //                         'Are you sure you want to close the case?'),
                    //                     function: () async {
                    //                       await _firestore
                    //                           .collection('alerts')
                    //                           .doc(camp.id)
                    //                           .update({
                    //                         'closed': true,
                    //                       });
                    //                     },
                    //                   );
                    //                 },
                    //           child: SizedBox(
                    //             width: screenWidth * 0.28,
                    //             child: Center(child: Text('Close Case')),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder(
  //     stream: _firestore.collection('camps').snapshots(),
  //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (!snapshot.hasData) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       var camps = snapshot.data!.docs;

  //       return ListView.builder(
  //         itemCount: camps.length,
  //         itemBuilder: (context, index) {
  //           var camp = camps[index];

  //           return Card(
  //             margin: const EdgeInsets.all(8),
  //             child: Padding(
  //               padding: const EdgeInsets.all(12),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   TextField(
  //                     readOnly: true,
  //                     controller: TextEditingController(
  //                         text: camp['latitude'].toString()),
  //                     decoration: InputDecoration(
  //                       labelText: 'Latitude',
  //                     ),
  //                   ),
  //                   TextField(
  //                     readOnly: true,
  //                     controller: TextEditingController(
  //                         text: camp['longitude'].toString()),
  //                     decoration: InputDecoration(
  //                       labelText: 'Longitude',
  //                     ),
  //                   ),
  //                   TextField(
  //                     readOnly: true,
  //                     controller: TextEditingController(
  //                         text: camp['userType'].toString()),
  //                     decoration: InputDecoration(
  //                       labelText: 'User Type',
  //                     ),
  //                   ),
  //                   TextField(
  //                     readOnly: true,
  //                     controller:
  //                         TextEditingController(text: camp['name'].toString()),
  //                     decoration: InputDecoration(
  //                       labelText: 'Name',
  //                     ),
  //                   ),
  //                   TextField(
  //                     readOnly: true,
  //                     controller: TextEditingController(
  //                         text: camp['comment'].toString()),
  //                     decoration: InputDecoration(
  //                       labelText: 'Comment',
  //                     ),
  //                   ),
  //                   TextField(
  //                     readOnly: true,
  //                     controller: TextEditingController(
  //                         text: (camp['is_open']) ? 'open' : 'closed'),
  //                     decoration: InputDecoration(
  //                       labelText: 'status',
  //                     ),
  //                   ),
  //                   if (camp['is_open'])
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         FilledButton(
  //                           onPressed: () {
  //                             showPopUp(context,
  //                                 popUpTitle: Text('Close Camp'),
  //                                 popUpContent: Text(
  //                                     'Are you sure you want to close the camp?'),
  //                                 function: () async {
  //                               await _firestore
  //                                   .collection('camps')
  //                                   .doc(camp.id)
  //                                   .update({
  //                                 'is_open': false,
  //                               });
  //                             });
  //                           },
  //                           child: const Text('Close Camp'),
  //                         ),
  //                       ],
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
