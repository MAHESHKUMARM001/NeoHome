import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:neohome_iot/iotcontrol.dart';

class ComponentsPage extends StatefulWidget {
  final String deviceId;

  const ComponentsPage({super.key, required this.deviceId});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _componentNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedComponentType;
  final List<String> _componentTypes = ['Switch', 'LCD', 'Gauge', 'Map', 'LED'];

  // Icons for each component type
  final Map<String, IconData> _componentIcons = {
    'Switch': Icons.toggle_on,
    'LCD': Icons.display_settings,
    'Gauge': Icons.speed,
    'Map': Icons.map,
    'LED': Icons.lightbulb,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _componentNameController.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Components',
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
          IoTControlPanel(deviceId: widget.deviceId),
          _buildCreateComponentTab(),
        ],
      ),
    );
  }
  
  








  Widget _buildCreateComponentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'images/addcomponent.svg',
                height: 300,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Component Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _componentNameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Component Name',
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
                prefixIcon: const Icon(Icons.memory, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a component name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Component Type',
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
                value: _selectedComponentType,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                hint: Text(
                  'Select component type',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
                items: _componentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _componentIcons[type],
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          type,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedComponentType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a component type';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _navigateToSetupPage,
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
                  'Continue to Setup',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSetupPage() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedComponentType == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComponentSetupPage(
          deviceId: widget.deviceId,
          componentName: _componentNameController.text.trim(),
          componentType: _selectedComponentType!,
        ),
      ),
    );
  }
}





class ComponentSetupPage extends StatefulWidget {
  final String deviceId;
  final String componentName;
  final String componentType;

  const ComponentSetupPage({
    super.key,
    required this.deviceId,
    required this.componentName,
    required this.componentType,
  });

  @override
  State<ComponentSetupPage> createState() => _ComponentSetupPageState();
}

class _ComponentSetupPageState extends State<ComponentSetupPage> {
  final TextEditingController _rangeStartController = TextEditingController();
  final TextEditingController _rangeEndController = TextEditingController();
  String? _selectedVirtualPin;
  bool _isLoading = false;
  List<String> _availablePins = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableVirtualPins();
  }

  Future<void> _loadAvailableVirtualPins() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('components')
        .where('deviceId', isEqualTo: widget.deviceId)
        .get(const GetOptions(source: Source.serverAndCache));

    final usedPins = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['virtualPin'].toString())
        .toList();

    print('Used pins for device ${widget.deviceId}: $usedPins'); // Debug log

    final allPins = List.generate(256, (index) => 'V$index');

    setState(() {
      _availablePins = allPins.where((pin) => !usedPins.contains(pin.substring(1))).toList();
      print('Available pins: $_availablePins'); // Debug log
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Setup ${widget.componentType}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                _getComponentIcon(widget.componentType),
                size: 80,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Virtual Pin Configuration',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _availablePins.isEmpty
                  ? TextFormField(
                readOnly: true,
                style: GoogleFonts.poppins(color: Colors.white70),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'No virtual pins available',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                ),
              )
                  : DropdownButtonFormField<String>(
                value: _selectedVirtualPin,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Select Virtual Pin',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: _availablePins.map((String pin) {
                  return DropdownMenuItem<String>(
                    value: pin,
                    child: Text(
                      pin,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVirtualPin = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a virtual pin';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            if (widget.componentType == 'Gauge') ...[
              Text(
                'Gauge Range Values',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rangeStartController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Start Value',
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter start value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: TextFormField(
                      controller: _rangeEndController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'End Value',
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter end value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addComponent,
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
                  'Add Component',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getComponentIcon(String type) {
    switch (type) {
      case 'Switch':
        return Icons.toggle_on;
      case 'LCD':
        return Icons.display_settings;
      case 'Gauge':
        return Icons.speed;
      case 'Map':
        return Icons.map;
      case 'LED':
        return Icons.lightbulb;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _addComponent() async {
    if (_selectedVirtualPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a virtual pin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.componentType == 'Gauge') {
      if (_rangeStartController.text.isEmpty || _rangeEndController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter range values for gauge'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Check if the selected pin is still available
    final snapshot = await FirebaseFirestore.instance
        .collection('components')
        .where('deviceId', isEqualTo: widget.deviceId)
        .where('virtualPin', isEqualTo: _selectedVirtualPin!.substring(1))
        .get();

    if (snapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This virtual pin is already in use'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final componentData = {
        'name': widget.componentName,
        'type': widget.componentType,
        'deviceId': widget.deviceId,
        'userId': user.uid,
        'virtualPin': _selectedVirtualPin!.substring(1),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'inactive',
        'lastUpdated': FieldValue.serverTimestamp(),
        'value': '',
      };

      if (widget.componentType == 'Gauge') {
        componentData['rangeStart'] = double.parse(_rangeStartController.text);
        componentData['rangeEnd'] = double.parse(_rangeEndController.text);
      }

      await FirebaseFirestore.instance.collection('components').add(componentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Component added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding component: ${e.toString()}'),
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
