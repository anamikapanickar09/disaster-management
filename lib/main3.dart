import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String serverKey =
      'BItvL2opu7T_BSXbin2MsLcuqLOY_qR7iHrqButfEzojjnyNoHxI5L8JHLyBoNtRAVLn96WMI-mX9Kuv2A5gCgc';
  final String topic = 'news';

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title}');
    });
  }

  Future<void> sendMessage() async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'to': '/topics/$topic',
          'notification': <String, dynamic>{
            'title': 'Breaking News',
            'body': 'Click to read the latest news!',
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print(
          'Failed to send message: ${response.reasonPhrase} ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FCM Topic Messaging')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Subscribed to "$topic" topic'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
