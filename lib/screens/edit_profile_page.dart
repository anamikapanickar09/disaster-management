import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _volunteerIdController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _doctorExperienceController =
      TextEditingController();
  final TextEditingController _doctorQualificationController =
      TextEditingController();
  final TextEditingController _workingStatusController =
      TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  String? imageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> changeEmail(String newEmail, String currentPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Re-authenticate the user before updating email
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(newEmail);
        // await user.sendEmailVerification(); // Optional: Ask user to verify new email
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Email updated!")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Re-authenticate the user before updating password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Password updated!")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userType = userDoc['userType'] ?? '';
          _userTypeController.text = userType;
          _emailController.text = user.email ?? '';
          _nameController.text = userDoc['name'] ?? '';
          _phoneController.text = ((userType == "victim")
                  ? userDoc['emergencyContact']
                  : userDoc['phone']) ??
              '';
          if (userType != 'victim') {
            _ageController.text = userDoc['age'] ?? '';
            _genderController.text = userDoc['gender'] ?? '';
            _workingStatusController.text = userDoc['workingStatus'] ?? '';
          }
          if (userType == "volunteer") {
            _volunteerIdController.text = userDoc['volunteerId'] ?? '';
          } else if (userType == "doctor") {
            _doctorIdController.text = userDoc['doctorId'] ?? '';
            _doctorExperienceController.text = userDoc['experience'] ?? '';
            _doctorQualificationController.text =
                userDoc['qualification'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> userData = {};
      if (userType == 'doctor') {
        userData = {
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _genderController.text.trim(),
          'qualification': _doctorQualificationController.text.trim(),
          'workingStatus': _workingStatusController.text.trim(),
          'experience': _doctorExperienceController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'doctorId': _doctorIdController.text.trim(),
        };
      } else if (userType == 'volunteer') {
        userData = {
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _genderController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'volunteerId': _volunteerIdController.text.trim(),
          'workingStatus': _workingStatusController.text.trim(),
        };
      } else if (userType == 'victim') {
        userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'emergencyContact': _phoneController.text.trim(),
        };
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated!')));
    }
  }

  Widget _makeTextBox(
      {required String title,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      bool editable = true}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration:
              InputDecoration(labelText: title, border: OutlineInputBorder()),
          enabled: editable,
          keyboardType: keyboardType,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          ElevatedButton(
            onPressed: _saveProfile,
            child: Text(
              "Save",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _makeTextBox(title: 'Name', controller: _nameController),
                    TextField(
                      controller: TextEditingController(text: "........"),
                      decoration: InputDecoration(
                          labelText: "Password", border: OutlineInputBorder()),
                      enabled: false,
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      enabled: false, // Email should not be editable
                    ),
                    SizedBox(height: 10),
                    if (userType != 'victim')
                      _makeTextBox(
                          title: 'Age',
                          controller: _ageController,
                          keyboardType: TextInputType.number),
                    // _makeTextBox(title: 'Email', controller: _emailController),
                    if (userType != 'victim')
                      _makeTextBox(
                          title: 'Gender', controller: _genderController),
                    _makeTextBox(
                        title: userType == 'victim'
                            ? 'Emergency Contact'
                            : 'Phone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone),
                    if (userType != 'victim')
                      _makeTextBox(
                          title: 'Working Status',
                          controller: _workingStatusController),
                    _makeTextBox(
                        title: 'User Type',
                        controller: _userTypeController,
                        editable: false),
                    if (userType == 'volunteer')
                      _makeTextBox(
                          title: 'Volunteer ID',
                          controller: _volunteerIdController),
                    if (userType == 'doctor')
                      _makeTextBox(
                          title: 'Doctor ID', controller: _doctorIdController),
                    if (userType == 'doctor')
                      _makeTextBox(
                          title: 'Job Experience (in years)',
                          controller: _doctorExperienceController),
                    if (userType == 'doctor')
                      _makeTextBox(
                          title: 'Qualification',
                          controller: _doctorQualificationController),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
