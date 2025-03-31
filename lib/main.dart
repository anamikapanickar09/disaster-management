import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart'; // Import the generated Firebase options
import 'screens/login_page.dart';
import 'screens/victim_home_page.dart';
import 'screens/doctor_home_page.dart';
import 'screens/volunteer_home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // _showNotification(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // Channel ID
  'High Importance Notifications', // Channel Name
  description:
      'This channel is used for important notifications.', // Channel Description
  importance: Importance.high,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options:
      //     DefaultFirebaseOptions.currentPlatform, // Set Firebase options for web
      );

  // Create notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.instance.subscribeToTopic("news");
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showNotification(message);
  });
  // Handle notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(message);
  });

  Widget homePage;
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      FirebaseFirestore.instance
          .collection("tokens")
          .doc(user.uid)
          .set({"token": token});
    }
    // Fetch user type from Firestore
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String userType = userDoc['userType'];

    if (userType == 'doctor') {
      homePage = const DoctorHomePage();
      FirebaseMessaging.instance.subscribeToTopic("doctor");
    } else if (userType == 'volunteer') {
      homePage = const VolunteerHomePage();
      FirebaseMessaging.instance.subscribeToTopic("volunteer");
    } else if (userType == 'victim') {
      homePage = const VictimHomePage();
      FirebaseMessaging.instance.subscribeToTopic("updates");
    } else {
      homePage = const LoginPage();
      FirebaseMessaging.instance.unsubscribeFromTopic("doctor");
      FirebaseMessaging.instance.unsubscribeFromTopic("volunteer");
      FirebaseMessaging.instance.unsubscribeFromTopic("updates");
    }
  } else {
    homePage = const LoginPage();
  }

  runApp(MyApp(homePage: homePage));
}

class MyApp extends StatelessWidget {
  final Widget homePage;
  const MyApp({super.key, required this.homePage});

  Future<void> askPermmissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    askPermmissions();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark), // 🌙 Dark mode
        useMaterial3: true,
      ),
    );
  }
}

void handleNotificationTap(RemoteMessage message) async {
  String userType = "user type";
  try {
    userType = (await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get())['userType'];
  } finally {
    print("$userType got ${message.data.toString()}");
  }
}

void _showNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
