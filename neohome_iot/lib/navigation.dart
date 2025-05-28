import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neohome_iot/about.dart';
import 'package:neohome_iot/contact.dart';
import 'package:neohome_iot/home.dart';
import 'package:neohome_iot/profile.dart';

import 'documentation.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
     AboutPage(),
    ContactPage(),
    NeoHomeDocumentationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NeoHome',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: _buildSideMenu(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade800,
              Colors.purple.shade800,
            ],
          ),
        ),
        child: _pages[_currentIndex],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: Colors.indigo.shade900,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with App Logo and Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade800,
                    Colors.indigo.shade900,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.smartphone_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'NeoHome IoT',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Smart Home Control',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    index: 0,
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    index: 1,
                  ),
                  _buildMenuItem(
                    icon: Icons.article_outlined,
                    title: 'Documentation',
                    index: 3,
                  ),
                  _buildMenuItem(
                    icon: Icons.contact_mail_outlined,
                    title: 'Contact',
                    index: 2,
                  ),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    index: 4,
                  ),

                  // const Divider(color: Colors.white24, height: 30),
                  // _buildMenuItem(
                  //   icon: Icons.settings_outlined,
                  //   title: 'Settings',
                  //   index: 5,
                  // ),
                ],
              ),
            ),

            // Footer with User Info

          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Colors.white.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: _currentIndex == index
              ? Colors.cyanAccent
              : Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: _currentIndex == index
                ? FontWeight.w600
                : FontWeight.normal,
            color: _currentIndex == index
                ? Colors.white
                : Colors.white70,
          ),
        ),
        trailing: _currentIndex == index
            ? Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(3),
          ),
        )
            : null,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Example Page Implementations
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.smartphone, size: 60, color: Colors.white),
//           const SizedBox(height: 20),
//           Text(
//             'Home Dashboard',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Control your smart home devices',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.white70,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AboutPage extends StatelessWidget {
//   const AboutPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.info, size: 60, color: Colors.white),
//           const SizedBox(height: 20),
//           Text(
//             'About NeoHome',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               'NeoHome is an advanced IoT platform for smart home automation and control.',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.white70,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ContactPage extends StatelessWidget {
//   const ContactPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.contact_mail, size: 60, color: Colors.white),
//           const SizedBox(height: 20),
//           Text(
//             'Contact Us',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildContactInfo(Icons.email, 'support@neohome.com'),
//           _buildContactInfo(Icons.phone, '+1 (555) 123-4567'),
//           _buildContactInfo(Icons.location_on, '123 IoT Street, Tech City'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContactInfo(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.cyanAccent),
//           const SizedBox(width: 10),
//           Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DocsPage extends StatelessWidget {
//   const DocsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.article, size: 60, color: Colors.white),
//           const SizedBox(height: 20),
//           Text(
//             'Documentation',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildDocItem('Getting Started'),
//           _buildDocItem('Device Setup'),
//           _buildDocItem('API Reference'),
//           _buildDocItem('Troubleshooting'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDocItem(String title) {
//     return Container(
//       width: 200,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.description, color: Colors.cyanAccent),
//           const SizedBox(width: 10),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircleAvatar(
//             radius: 50,
//             backgroundImage: NetworkImage(
//               'https://randomuser.me/api/portraits/men/32.jpg',
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Admin User',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             'admin@neohome.com',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildProfileButton('Edit Profile'),
//           _buildProfileButton('Change Password'),
//           _buildProfileButton('Notification Settings'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileButton(String text) {
//     return Container(
//       width: 200,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white.withOpacity(0.1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           text,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.settings, size: 60, color: Colors.white),
//           const SizedBox(height: 20),
//           Text(
//             'Settings',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildSettingSwitch('Dark Mode', true),
//           _buildSettingSwitch('Notifications', true),
//           _buildSettingSwitch('Auto Update', false),
//           const SizedBox(height: 20),
//           _buildSettingsButton('Advanced Settings'),
//           _buildSettingsButton('Logout'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSettingSwitch(String text, bool value) {
//     return Container(
//       width: 250,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             text,
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//           Switch(
//             value: value,
//             activeColor: Colors.cyanAccent,
//             onChanged: (bool newValue) {},
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSettingsButton(String text) {
//     return Container(
//       width: 200,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: OutlinedButton(
//         onPressed: () {},
//         style: OutlinedButton.styleFrom(
//           side: BorderSide(color: Colors.white.withOpacity(0.3)),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           text,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }