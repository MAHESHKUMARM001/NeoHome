import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neohome_iot/component.dart';

class CreateDevicePage extends StatefulWidget {
  final String templateId;

  const CreateDevicePage({super.key, required this.templateId});

  @override
  State<CreateDevicePage> createState() => _CreateDevicePageState();
}

class _CreateDevicePageState extends State<CreateDevicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _deviceNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedBoard;
  final List<String> _boardTypes = ['ESP32', 'ESP8266'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Dark blue background
    appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pop(context),
    ),
    title: Text(
    'Manage Devices',
    style: GoogleFonts.poppins(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    ),
    ),
    bottom: TabBar(
    controller: _tabController,
    labelColor: Colors.blueAccent,
    unselectedLabelColor: Colors.white70,
    indicatorColor: Colors.blueAccent,
    indicatorSize: TabBarIndicatorSize.tab,
    indicatorWeight: 3,
    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
    tabs: const [
    Tab(icon: Icon(Icons.list_alt)),
    Tab(icon: Icon(Icons.add_circle_outline)),
    ],
    ),
    ),
    body: TabBarView(
    controller: _tabController,
    children: [
    // Tab 1: Device List
    _buildDeviceListTab(),

    // Tab 2: Create Device
    _buildCreateDeviceTab(),
    ],
    ),
    );
  }

  Widget _buildDeviceListTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('devices')
          .where('templateId', isEqualTo: widget.templateId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading devices',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'images/nodevice.svg', // Add your SVG asset
                  height: 250,
                  // color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'No devices found',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(1); // Switch to create tab
                  },
                  child: Text(
                    'Add your first device',
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final device = doc.data() as Map<String, dynamic>;
            final createdAt = (device['createdAt'] as Timestamp).toDate();
            final formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      'images/${device['boardType'].toString().toLowerCase()}.jpg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                title: Text(
                  device['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${device['boardType']} • $formattedDate',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                onTap: () {
                  // Navigate to device details page
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) => DeviceDetailsPage(deviceId: doc.id),
                  // ));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComponentsPage(deviceId: doc.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateDeviceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration
            Center(
              child: SvgPicture.asset(
                'images/deviceimage.svg', // Add your SVG asset
                height: 250,
              ),
            ),

            const SizedBox(height: 32),

            // Device Name Input
            Text(
              'Device Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _deviceNameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Device Name',
                labelStyle: GoogleFonts.poppins(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                prefixIcon: const Icon(Icons.devices_other, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a device name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Board Type Dropdown
            Text(
              'Board Type',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedBoard,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                hint: Text(
                  'Select board type',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
                items: _boardTypes.map((String board) {
                  return DropdownMenuItem<String>(
                    value: board,
                    child: Row(
                      children: [
                        Image.asset(
                          'images/${board.toLowerCase()}.jpg',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          board,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBoard = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a board type';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 40),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                )
                    : Text(
                  'Add Device',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDevice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBoard == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance.collection('devices').add({
        'name': _deviceNameController.text.trim(),
        'boardType': _selectedBoard,
        'templateId': widget.templateId,
        // 'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        // 'status': 'inactive',
        // 'lastSeen': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device added successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form and switch to list tab
      _deviceNameController.clear();
      setState(() => _selectedBoard = null);
      _tabController.animateTo(0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding device: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}