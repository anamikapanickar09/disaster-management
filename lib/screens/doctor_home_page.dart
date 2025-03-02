import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'map_page.dart';
import 'notification_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildFeatureBox(
            title: "Map View",
            icon: Icons.map,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
          ),
          SizedBox(height: 16),
          _buildFeatureBox(
            title: "Update Alerts",
            icon: Icons.edit,
            color: Colors.orange,
            onTap: () => _showUpdateAlerts(context),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Emergency Contacts",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                _contactRow("Fire Department", "101"),
                _contactRow("Ambulance", "102"),
                _contactRow("Police", "100"),
                _contactRow("Disaster Helpline", "108"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateAlerts(BuildContext context) async {
    Location location = Location();
    var currentLocation = await location.getLocation();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nearby Alerts"),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('alerts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var alerts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    var alert = alerts[index];
                    return ListTile(
                      title: Text(alert['comment']),
                      subtitle: Text(
                          "Lat: ${alert['latitude']}, Lng: ${alert['longitude']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.deepPurple),
                        onPressed: () {
                          _showEditAlertDialog(
                              context, alert.id, alert['comment']);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showEditAlertDialog(
      BuildContext context, String alertId, String oldComment) {
    TextEditingController editController =
        TextEditingController(text: oldComment);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Alert"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: "Updated Comment",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('alerts')
                    .doc(alertId)
                    .update({'comment': editController.text});
                Navigator.pop(context);
                Navigator.pop(context); // Close the list of alerts too
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureBox({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(String title, String number) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12)),
          Text(number,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
