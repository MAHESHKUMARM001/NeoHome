import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: Text(
      //     'Privacy Policy',
      //     style: GoogleFonts.poppins(
      //       fontSize: isSmallScreen ? 20 : 24,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.indigo.shade800,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating elements
            Positioned(
              top: size.height * 0.1,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.1),
                ),
              ),
            ),
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24 : 48,
                vertical: 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyanAccent.withOpacity(0.3),
                                Colors.blueAccent.withOpacity(0.3),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/privacy_shield.svg',
                              width: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Privacy Policy',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Last Updated: June 2024',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Privacy Policy Content
                  _buildPrivacySection(
                    title: '1. Data We Collect',
                    content:
                    'NeoHome IoT collects device information, usage data, and sensor readings to provide personalized automation. We do not store personal identifiers without consent.',
                  ),
                  _buildPrivacySection(
                    title: '2. How We Use Your Data',
                    content:
                    'We use collected data to improve app functionality, provide smart home automation, and enhance security. Your data is never sold to third parties.',
                  ),
                  _buildPrivacySection(
                    title: '3. Data Security',
                    content:
                    'All data transmitted between your devices and our servers is encrypted using AES-256. We follow industry best practices to protect your information.',
                  ),
                  _buildPrivacySection(
                    title: '4. Third-Party Services',
                    content:
                    'We integrate with Google Maps (for geofencing) and Firebase (for analytics). These services have their own privacy policies.',
                  ),
                  _buildPrivacySection(
                    title: '5. Your Rights',
                    content:
                    'You can request data deletion, export your settings, or opt out of analytics at any time via the app settings.',
                  ),
                  const SizedBox(height: 40),

                  // Acceptance & Contact
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By using NeoHome IoT, you agree to this Privacy Policy.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'For any privacy concerns, contact us at:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email_rounded, color: Colors.cyanAccent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'privacy@neohomeiot.com',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}