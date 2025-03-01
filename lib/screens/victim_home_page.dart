import 'package:flutter/material.dart';
import 'map_page.dart';

class VictimHomePage extends StatelessWidget {
  const VictimHomePage({super.key});

  void _showEmergencyAlert(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emergency Alert"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send an emergency alert to other users."),
              SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "Emergency Comments",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle alert sending logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Send Alert"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster Response"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              children: [
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
                _buildFeatureBox(
                  title: "Alert",
                  icon: Icons.warning,
                  color: Colors.red,
                  onTap: () => _showEmergencyAlert(context),
                  blinking: true,
                ),
                _buildFeatureBox(
                  title: "GPT Help",
                  icon: Icons.help,
                  color: Colors.green,
                  onTap: () {
                    // Handle AI help feature
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Emergency Contacts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
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

  Widget _buildFeatureBox({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool blinking = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: blinking ? Colors.red.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            Positioned(
              bottom: 8,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(String title, String number) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(number,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
