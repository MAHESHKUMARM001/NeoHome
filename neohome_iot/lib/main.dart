import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:neohome_iot/control.dart';
import 'package:neohome_iot/iotcontrol.dart';
import 'package:neohome_iot/login.dart';
import 'package:neohome_iot/navigation.dart';
import 'package:neohome_iot/phonenumber.dart';
import 'package:neohome_iot/sidemenu.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _getHomeScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? MainNavigation() : LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: FutureBuilder<bool>(
      //   future: PrefsHelper.isFirstLaunch(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Scaffold(body: Center(child: CircularProgressIndicator()));
      //     }
      //
      //     if (snapshot.data == true) {
      //       return OnboardingFlow(
      //         onComplete: () async {
      //           await PrefsHelper.setFirstLaunchComplete();
      //           Navigator.of(context).pushReplacement(
      //             MaterialPageRoute(builder: (context) => _getHomeScreen()),
      //           );
      //         },
      //       );
      //     } else {
      //       return _getHomeScreen();
      //     }
      //   },
      // ),
      home: _getHomeScreen(),
      // home: IoTControlPanel(deviceId: "NECZUJYfR1f5lO2rMIgl"),
      // home: ControlPanel(),
      // home: PhoneNumber(),
      // home: LoginPage(),
      // home: SideMenu(),
      // home: MainNavigation(),

      // home: CreateTemplatePage(),
      // home: Intro2(),
    );
  }
}