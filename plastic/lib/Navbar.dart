import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plastic/Camera.dart';
import 'package:plastic/Home.dart';
import 'package:plastic/Notification.dart';
import 'package:plastic/Profile.dart';



class Navbar extends StatefulWidget {


  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int userCoins = 0; // Store the user's coins count


  @override
  void initState() {
    super.initState();
    _fetchUserCoins(); // Fetch coins when the widget initializes
  }

  Future<void> _fetchUserCoins() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userCoins = userDoc['coins'] ?? 0;
        });
      }
    }
  }

  // Updated pages
  static List<Widget> _widgetOptions(Navbar widget) => <Widget>[
    HomePage(), // Home Page
    CameraPage(),
    NotificationPage(),
    ProfilePage(),
    // CameraPage(), // Camera Page
    // ProductListPage(), // Product List Page
    // ProfilePage(), // Profile Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFFD0FFBA).withOpacity(0.3),
        title:
            Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'images/plasticlogo1.png', // Replace with your logo
                    height: 50,
                  ),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.yellow),
                      SizedBox(width: 5),
                      Text(
                        '$userCoins',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            )

      ),


      body: Stack(
        children: [
          _widgetOptions(widget)[_selectedIndex],
          if (_isMenuOpen) _buildSideMenu(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: _selectedIndex == 0 ? Colors.white : Colors.black),
          Icon(Icons.camera_alt, size: 30, color: _selectedIndex == 1 ? Colors.white : Colors.black),
          Icon(Icons.notifications, size: 30, color: _selectedIndex == 2 ? Colors.white : Colors.black),
          Icon(Icons.account_circle_outlined, size: 30, color: _selectedIndex == 3 ? Colors.white : Colors.black),
        ],
        color: Color(0xFF6bb848),
        buttonBackgroundColor: Color(0xFF6bb848),
        backgroundColor: Color(0XFFD0FFBA).withOpacity(0.3),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSideMenu() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeInOut,
      )),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
            ),
          ],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6bb848),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                _onItemTapped(0);
                _toggleMenu();
              },
            ),
            ListTile(
              title: Text('Camera'),
              onTap: () {
                _onItemTapped(1);
                _toggleMenu();
              },
            ),
            ListTile(
              title: Text('Product List'),
              onTap: () {
                _onItemTapped(2);
                _toggleMenu();
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                _onItemTapped(3);
                _toggleMenu();
              },
            ),
          ],
        ),
      ),
    );
  }
}
