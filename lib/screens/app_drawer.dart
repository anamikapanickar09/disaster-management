import 'package:disaster/screens/edit_profile_page.dart';
import 'package:disaster/screens/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/pop_up.dart';
import './about_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          String name = userData['name'] ?? 'User';
          // String profilePic = userData['profilePic'] ?? ''; // If available

          return ListView(
            children: [
              // UserAccountsDrawerHeader(
              //   accountName:
              //   accountEmail: null, // Remove if not needed
              //   currentAccountPicture: Expanded(
              //     child: Center(
              //       child:
              //     ),
              //   ),
              // ),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      foregroundImage: AssetImage(
                        "assets/avatar.png",
                      ),
                      backgroundColor: Colors.transparent,
                      radius: 55,
                    ),
                    Center(child: Text(name, style: TextStyle(fontSize: 18))),
                    if (userData["userType"] != "victim")
                      Center(
                          child: Text(
                              userData["userType"].toString().toUpperCase(),
                              style: TextStyle(fontSize: 14))),
                  ],
                ),
              ),
              DrawerItem(
                  icon: Icons.home,
                  text: "Home",
                  onTap: () {
                    Navigator.pop(context);
                  }),
              DrawerItem(
                  icon: Icons.edit,
                  text: "Profile",
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditProfilePage();
                    }));
                  }),
              // DrawerItem(icon: Icons.info, text: "App Info", onTap: () {}),
              DrawerItem(
                  icon: Icons.help,
                  text: "About",
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return AboutPage();
                    }));
                  }),
              DrawerItem(
                icon: Icons.logout,
                text: "Logout",
                onTap: () async {
                  bool isLoading = false;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (BuildContext context, setState) {
                        return AlertDialog(
                          backgroundColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            "Logout",
                            style: TextStyle(fontSize: 17),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              !isLoading
                                  ? Text(
                                      "Do you want to logout the application?",
                                      style: TextStyle(fontSize: 15),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: CircularProgressIndicator(),
                                    ),
                            ],
                          ),
                          actions: [
                            if (!isLoading)
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            if (!isLoading)
                              TextButton(
                                onPressed: () async {
                                  setState(
                                    () => isLoading = true,
                                  );
                                  await FirebaseAuth.instance.signOut();

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                    );
                                  }
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic("doctor");
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic("volunteer");
                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic("updates");
                                  return;
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black26,
                                ),
                                child: Text(
                                  "Logout",
                                ),
                              ),
                          ],
                        );
                      });
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
    return;
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const DrawerItem(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        // color: Colors.black54,
      ),
      title: Text(text, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
