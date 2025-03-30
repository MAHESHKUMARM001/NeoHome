import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plastic/Navbar.dart';
import 'package:plastic/Navbar1.dart';
import 'package:plastic/Redeem_coins.dart';
import 'package:plastic/login.dart';
import 'package:plastic/rezopay.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _getHomeScreen() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if the email is the admin's email
      if (user.email == "bneeraj7187@gmail.com") {
        return Navbar1(); // Admin panel
      } else {
        return Navbar(); // Regular user panel
      }
    } else {
      return LoginPage(); // If no user is logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: _getHomeScreen(), // Choose the correct screen dynamically
      // home: RedeemCoinsPage(),
      // home: Rezopay(),
    );
  }
}
