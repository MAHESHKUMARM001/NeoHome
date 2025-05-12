import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NeoHomeDocumentationPage extends StatefulWidget {
  const NeoHomeDocumentationPage({super.key});

  @override
  State<NeoHomeDocumentationPage> createState() => _NeoHomeDocumentationPageState();
}

class _NeoHomeDocumentationPageState extends State<NeoHomeDocumentationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _scrollController = ScrollController();
  final _expandedSections = List<bool>.generate(5, (_) => false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _toggleSection(int index) {
    setState(() {
      _expandedSections[index] = !_expandedSections[index];
    });
  }

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
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: size.height * 0.15,
              left: -100,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value * 40),
                    child: child,
                  );
                },
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyanAccent.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.1,
              right: -50,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_animation.value * 30),
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.15,
                      left: isSmallScreen ? 24 : 48,
                      right: isSmallScreen ? 24 : 48,
                      bottom: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.cyanAccent.withOpacity(0.3),
                                      Colors.blueAccent.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  'assets/iot_logo.svg',
                                  width: 80,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'NeoHome IoT Documentation',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 28 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Complete guide to setting up and managing your IoT devices',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // Documentation Sections
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDocumentationSection(
                      context,
                      index: 0,
                      icon: Icons.dashboard_customize_rounded,
                      title: "Creating Templates",
                      content: _buildTemplateContent(),
                    ),
                    _buildDocumentationSection(
                      context,
                      index: 1,
                      icon: Icons.devices_rounded,
                      title: "Creating Devices",
                      content: _buildDevicesContent(),
                    ),
                    _buildDocumentationSection(
                      context,
                      index: 2,
                      icon: Icons.widgets_rounded,
                      title: "Creating Components",
                      content: _buildComponentsContent(),
                    ),
                    _buildDocumentationSection(
                      context,
                      index: 3,
                      icon: Icons.control_camera_rounded,
                      title: "Controlling IoT Devices",
                      content: _buildControlContent(),
                    ),
                    _buildDocumentationSection(
                      context,
                      index: 4,
                      icon: Icons.code_rounded,
                      title: "Arduino Library Integration",
                      content: _buildArduinoContent(),
                    ),
                    const SizedBox(height: 60),
                  ]),
                ),
              ],
            ),
            // Floating action button
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                onPressed: () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
                backgroundColor: Colors.cyanAccent.withOpacity(0.9),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentationSection(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String title,
        required Widget content,
      }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 24 : 48,
        vertical: 8,
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white.withOpacity(0.08),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            onExpansionChanged: (expanded) => _toggleSection(index),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.3),
                    Colors.blueAccent.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              _expandedSections[index]
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates help you standardize device configurations for reuse across multiple devices.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Navigate to Templates',
          description: 'Go to the "Templates" section in the app menu',
        ),
        _buildStep(
          number: 2,
          title: 'Create New Template',
          description: 'Click the "+" button to create a new template',
        ),
        _buildStep(
          number: 3,
          title: 'Configure Components',
          description: 'Add all components that will be common to devices using this template',
        ),
        const SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.auto_awesome_mosaic_rounded,
          title: 'Template Features',
          features: const [
            'Pre-configure common device types',
            'Enforce consistency across devices',
            'Reduce setup time for new devices',
          ],
        ),
      ],
    );
  }

  Widget _buildDevicesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Devices represent your physical IoT hardware in the app. Each device connects to your NeoHome system.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Add New Device',
          description: 'Tap "Add Device" from the dashboard',
        ),
        _buildStep(
          number: 2,
          title: 'Select Template',
          description: 'Choose from existing templates or create custom',
        ),
        _buildStep(
          number: 3,
          title: 'Device Configuration',
          description: 'Enter device-specific parameters and credentials',
        ),
        const SizedBox(height: 20),
        _buildCodeBlock(
          title: 'Example Device Registration',
          code: '''
// In your Arduino code
neohome.begin(
  wifiSSID,       // Your WiFi SSID
  wifiPassword,   // Your WiFi password
  deviceId        // Unique device ID
);
          ''',
        ),
      ],
    );
  }

  Widget _buildComponentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Components are the building blocks of your IoT devices - sensors, actuators, and controls.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Add Component',
          description: 'From device page, tap "Add Component"',
        ),
        _buildStep(
          number: 2,
          title: 'Select Type',
          description: 'Choose from sensor, switch, display, etc.',
        ),
        _buildStep(
          number: 3,
          title: 'Configure Pins',
          description: 'Map to physical pins on your hardware',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildComponentType(
              icon: Icons.thermostat_rounded,
              name: 'Temperature',
              color: Colors.orangeAccent,
            ),
            _buildComponentType(
              icon: Icons.water_drop_rounded,
              name: 'Humidity',
              color: Colors.blueAccent,
            ),
            _buildComponentType(
              icon: Icons.light_mode_rounded,
              name: 'Light',
              color: Colors.yellowAccent,
            ),
            _buildComponentType(
              icon: Icons.location_on_rounded,
              name: 'GPS',
              color: Colors.greenAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Control your IoT devices through the app interface or automated routines.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Device Dashboard',
          description: 'Access all controls from the main dashboard',
        ),
        _buildStep(
          number: 2,
          title: 'Real-time Monitoring',
          description: 'View sensor data as it updates',
        ),
        _buildStep(
          number: 3,
          title: 'Manual Control',
          description: 'Toggle switches and adjust settings',
        ),
        const SizedBox(height: 20),
        _buildCodeBlock(
          title: 'Example Control Code',
          code: '''
// Control LED from virtual pin 4
String value = neohome.read(deviceId, 4);

if (value == "1") {
    digitalWrite(ledPin, HIGH); // Turn ON
} else if (value == "0") {
    digitalWrite(ledPin, LOW);  // Turn OFF
}
          ''',
        ),
      ],
    );
  }

  Widget _buildArduinoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrate your Arduino devices with the NeoHome library for seamless connectivity.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildStep(
          number: 1,
          title: 'Install Library',
          description: 'Add the NeoHome library to your Arduino IDE',
        ),
        _buildStep(
          number: 2,
          title: 'Include Dependencies',
          description: 'Add required libraries for your sensors',
        ),
        _buildStep(
          number: 3,
          title: 'Configure Device',
          description: 'Set up WiFi and device parameters',
        ),
        const SizedBox(height: 20),
        _buildCodeBlock(
          title: 'Full Arduino Example',
          code: '''
#include <NeoHome.h>
#include <DHT.h>
#include <TinyGPS++.h>

// Device configuration
const char* deviceId = "YOUR_DEVICE_ID";
const char* wifiSSID = "YOUR_WIFI";
const char* wifiPassword = "YOUR_PASSWORD";

// Pin definitions
const int ledPin = 2;
const int dhtPin = 4;
DHT dht(dhtPin, DHT11);

NeoHome neohome;

void setup() {
    Serial.begin(115200);
    pinMode(ledPin, OUTPUT);
    dht.begin();
    neohome.begin(wifiSSID, wifiPassword, deviceId);
}

void loop() {
    // Read temperature
    float temperature = dht.readTemperature();
    if (!isnan(temperature)) {
        neohome.write(deviceId, 1, String(temperature, 2));
    }
    
    // Device control handling
    String value = neohome.read(deviceId, 4);
    if (value == "1") digitalWrite(ledPin, HIGH);
    else if (value == "0") digitalWrite(ledPin, LOW);
    
    delay(100);
}
          ''',
        ),
        const SizedBox(height: 20),
        Text(
          'For complete documentation, visit our GitHub repository:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchUrl('https://github.com/your-repo'),
          child: Text(
            'github.com/your-repo',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.cyanAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyanAccent.withOpacity(0.2),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyanAccent.withOpacity(0.05),
            Colors.blueAccent.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features
                .map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.cyanAccent.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock({required String title, required String code}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.4),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: Colors.cyanAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentType({
    required IconData icon,
    required String name,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}