import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(

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
                              'assets/terms_document.svg',
                              width: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Terms & Conditions',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Effective Date: June 2024',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Terms Content
                  _buildTermSection(
                    icon: Icons.gavel_rounded,
                    title: '1. Acceptance of Terms',
                    content:
                    'By accessing or using the NeoHome IoT application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use the App.',
                  ),

                  _buildTermSection(
                    icon: Icons.account_circle_rounded,
                    title: '2. User Accounts',
                    content:
                    'You must provide accurate information when creating an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                  ),

                  _buildTermSection(
                    icon: Icons.security_rounded,
                    title: '3. Acceptable Use',
                    content:
                    'You agree not to use the App for any unlawful purpose or in any way that could damage the App or impair other users\' experience. Prohibited activities include reverse engineering, spamming, or attempting to gain unauthorized access to other systems.',
                  ),

                  _buildTermSection(
                    icon: Icons.monetization_on_rounded,
                    title: '4. Subscription & Payments',
                    content:
                    'Premium features may require a subscription. All payments are non-refundable except as required by law. We reserve the right to modify subscription fees with 30 days notice.',
                  ),

                  _buildTermSection(
                    icon: Icons.assignment_rounded,
                    title: '5. Intellectual Property',
                    content:
                    'All content, features, and functionality of the App are the exclusive property of NeoHome IoT and its licensors. The App is licensed, not sold, to you for use under these terms.',
                  ),

                  _buildTermSection(
                    icon: Icons.warning_rounded,
                    title: '6. Disclaimer of Warranties',
                    content:
                    'The App is provided "as is" without warranties of any kind. We do not guarantee that the App will be uninterrupted or error-free. Smart home automation carries inherent risks - you assume all responsibility for device operation.',
                  ),

                  _buildTermSection(
                    icon: Icons.workspace_premium_rounded,
                    title: '7. Limitation of Liability',
                    content:
                    'NeoHome IoT shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App. Our total liability shall not exceed the amount you paid for the App in the last 12 months.',
                  ),

                  _buildTermSection(
                    icon: Icons.update_rounded,
                    title: '8. Modifications',
                    content:
                    'We may modify these Terms at any time. Continued use after changes constitutes acceptance. Material changes will be notified via email or in-app notice at least 30 days before taking effect.',
                  ),

                  _buildTermSection(
                    icon: Icons.balance_rounded,
                    title: '9. Governing Law',
                    content:
                    'These Terms shall be governed by the laws of [Your Country/State]. Any disputes shall be resolved in the courts located in [Jurisdiction].',
                  ),

                  const SizedBox(height: 40),

                  // Acceptance Section
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
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.cyanAccent, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Your Acceptance',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'By using NeoHome IoT, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'For questions about these Terms, contact us at:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email_rounded,
                                color: Colors.cyanAccent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'legal@neohomeiot.com',
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

  Widget _buildTermSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.3),
                      Colors.blueAccent.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}