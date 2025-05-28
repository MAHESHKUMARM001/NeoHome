import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  // final smtpServer = gmail('maheshkumarm001234@gmail.com', 'mahesh001234');

  // OpenStreetMap configuration
  static const latlong.LatLng _hqLocation = latlong.LatLng(9.43639,77.55444); // San Francisco, CA
  final MapController _mapController = MapController();

  bool _isLoadingGetLocation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw "Could not launch $url";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open link: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void sendMailDirectly() async {
    final smtpServer = gmail('maheshkumarm001234@gmail.com', 'zjlp grwq nxfw cjqt'); // Use app password

    final message = Message()
      ..from = Address(_emailController.text, _nameController.text) // Use .text property
      ..recipients.add('hashanmedicare@gmail.com')
      ..subject = 'Message from ${_nameController.text}' // Added subject with name
      ..text = _messageController.text; // Use .text property

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. $e');
      // You might want to show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message. Please try again.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _submitMessage() {
    setState(() {
      _isLoading = true;
    });
    // Simulate form submission
    sendMailDirectly();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Message sent successfully!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.cyanAccent,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // height: size.height * 1.8, // Adjusted for content
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.indigo.shade800,
                Colors.purple.shade800,
              ],
            ),
          ),
          child: Stack(
            children: [
          // Animated background elements
          Positioned(
          top: size.height * 0.1,
            left: -50,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value * 20),
                  child: child,
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            right: -30,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_animation.value * 20),
                  child: child,
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            SizedBox(height: size.height * 0.1),
            // Header
            Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/iot_logo.svg',
                    width: 60,
                    color: Colors.cyanAccent,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Contact Us',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Get in touch with NeoHome IoT',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05),

            // OpenStreetMap
            Text(
              'Our Location',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _hqLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _hqLocation,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // ElevatedButton(onPressed: () => _launchUrl("https://maps.app.goo.gl/dMazGVvFGZb883yv7"),
            //     child: Text("Get Location")),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoadingGetLocation
                          ? null
                          : () => _launchUrl("https://maps.app.goo.gl/dMazGVvFGZb883yv7"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.cyanAccent.withOpacity(0.5),
                      ),
                      child: _isLoadingGetLocation
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : Text(
                        'GET LOCATION',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

            SizedBox(height: size.height * 0.05),

            // Contact Details
            Text(
              'Contact Details',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.location_on,
                    text: '276N1, SankaranKovil Road, Rajapalayam, Backside of RasiMahal',
                  ),
                  const SizedBox(height: 15),
                  _buildContactItem(
                    icon: Icons.phone,
                    text: '+91 7904685847',
                    onTap: () => _launchUrl('tel:+917904685847'),
                  ),
                  const SizedBox(height: 15),
                  _buildContactItem(
                    icon: Icons.email,
                    text: 'hashanmedicare@gmail.com',
                    onTap: () => _launchUrl('mailto:hashanmedicare@gmail.com'),
                  ),
                  const SizedBox(height: 15),
                  _buildContactItem(
                    icon: Icons.access_time,
                    text: 'Mon-Sat, 9:00 AM - 7:00 PM PST',
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Connect with Us
            Text(
              'Connect with Us',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialIcon('images/twitter.jpg', 'https://twitter.com/smarthomeiot'),
              // const SizedBox(width: 20),
              _buildSocialIcon('images/linkedinlogo.png', 'https://www.linkedin.com/in/maheshkumar-m-3778b823a/'),
              // const SizedBox(width: 20),
              _buildSocialIcon('images/instagramlogo.jpg', 'https://www.instagram.com/hashanmedicare'),
              // const SizedBox(width: 20),
              _buildSocialIcon('images/facebook.png', 'https://instagram.com/smarthomeiot'),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.05),

        // Send a Message
        Text(
          'Send a Message',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Name Field
              TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your Name',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Email Field
              TextField(
                controller: _emailController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your Email',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              // Message Field
              TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your Message',
                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                  prefixIcon: const Icon(Icons.message, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    'SEND MESSAGE',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.05),
        ],
      ),
    ),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String asset, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Image.asset(
        asset,
        width: 35,
        height: 35,
        // color: Colors.cyanAccent,
      ),
    );
  }
}