import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastic/login.dart';

class ProfilePage1 extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? name;
  String? email;
  String? phone;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      print("iugudghbuhghuwhubsjijsdugfvsdcvhsdvc");
      print(userDoc.exists);
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'];
          email = userDoc['email'];
          phone = userDoc['phone'];
        });
        print(name);
      }
    }
  }

  void _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    // Navigator.pushReplacementNamed(context, MaterialPageRoute(builder: (context) => HomePage()),); // Redirect to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0XFFD0FFBA).withOpacity(0.3),

      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("you are in admin page"),
            Text("Name: ${name ?? 'Loading...'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Email: ${email ?? 'Loading...'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Phone: ${phone ?? 'Not Available'}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Logout",
                  style: TextStyle(
                      color: Colors.white
                  ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
