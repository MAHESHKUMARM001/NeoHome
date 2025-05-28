import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IoTControlPanel extends StatefulWidget {
  final String deviceId;

  const IoTControlPanel({Key? key, required this.deviceId}) : super(key: key);

  @override
  _IoTControlPanelState createState() => _IoTControlPanelState();
}

class _IoTControlPanelState extends State<IoTControlPanel> {
  MqttServerClient? client;
  String _connectionStatus = 'Disconnected';
  String _lastUpdate = 'Never';
  final String _mqttServer = '18.175.142.227';
  final String _clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

  // Component management
  final Map<String, dynamic> _componentStates = {};
  final Map<String, dynamic> _componentConfigs = {};
  bool _initialStateLoaded = true;

  // Topics
  final String _stateRequestTopic = 'state/request';
  final String _stateResponseTopic = 'state/response';

  LatLng? userLocation;
  LatLng? destination;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _loadComponents().then((_) => _connectToMqtt());
    requestLocationPermission();
  }

  Future<void> _loadComponents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('components')
          .where('deviceId', isEqualTo: widget.deviceId)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        setState(() {
          _componentConfigs[doc.id] = data;
          _componentStates[doc.id] = {
            'value': data['defaultValue'] ?? '',
            'updatedAt': DateTime.now(),
          };
        });
      }
    } catch (e) {
      print('Error loading components: $e');
    }
  }

  Future<void> _connectToMqtt() async {
    setState(() => _connectionStatus = 'Connecting...');

    client = MqttServerClient(_mqttServer, _clientId);
    client!.port = 1883;
    client!.setProtocolV311();
    client!.keepAlivePeriod = 30;
    client!.onDisconnected = _onDisconnected;
    client!.logging(on: false);

    try {
      await client!.connect();
    } catch (e) {
      setState(() => _connectionStatus = 'Connection failed: $e');
      return;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _setupMqttSubscriptions();
      setState(() => _connectionStatus = 'Connected');
    } else {
      setState(() => _connectionStatus = 'Connection failed');
    }
  }

  void _setupMqttSubscriptions() {
    // Subscribe to all component topics
    for (var componentId in _componentConfigs.keys) {
      final config = _componentConfigs[componentId];
      final dataTopic = '${widget.deviceId}/${config['virtualPin']}';
      final commandTopic = '${widget.deviceId}/${config['virtualPin']}/command';

      client!.subscribe(dataTopic, MqttQos.atLeastOnce);

      // Only subscribe to command topics for switches
      if (config['type'] == 'Switch') {
        client!.subscribe(commandTopic, MqttQos.atLeastOnce);
      }
    }

    // Subscribe to state response
    final stateResponseTopic = '${widget.deviceId}/$_stateResponseTopic';
    client!.subscribe(stateResponseTopic, MqttQos.atLeastOnce);

    // Request initial state
    _requestInitialState();

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final payload = MqttPublishPayload.bytesToStringAsString(
            (message.payload as MqttPublishMessage).payload.message);

        setState(() {
          _lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());

          // Handle state response
          if (message.topic == '${widget.deviceId}/$_stateResponseTopic') {
            _processStateResponse(payload);
            return;
          }

          // Handle component updates
          for (var componentId in _componentConfigs.keys) {
            final config = _componentConfigs[componentId];
            final baseTopic = '${widget.deviceId}/${config['virtualPin']}';

            if (message.topic == baseTopic || message.topic == '$baseTopic/command' ) {
              _componentStates[componentId] = {
                'value': payload,
                'updatedAt': DateTime.now(),
              };
              break;
            }
          }
        });
      }
    });
  }

  void _requestInitialState() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('get_state');

    client!.publishMessage(
      '${widget.deviceId}/$_stateRequestTopic',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  void _processStateResponse(String payload) {
    try {
      final stateParts = payload.split(';');
      for (var part in stateParts) {
        final componentState = part.split(':');
        if (componentState.length == 2) {
          final componentId = componentState[0];
          final value = componentState[1];

          if (_componentStates.containsKey(componentId)) {
            setState(() {
              _componentStates[componentId] = {
                'value': value,
                'updatedAt': DateTime.now(),
              };
            });
          }
        }
      }
      _initialStateLoaded = true;
    } catch (e) {
      print('Error processing state response: $e');
    }
  }

  void _sendComponentCommand(String componentId, String value) {
    final config = _componentConfigs[componentId];
    if (config == null || config['type'] != 'Switch') return;

    final topic = '${widget.deviceId}/${config['virtualPin']}/command';
    final builder = MqttClientPayloadBuilder();
    builder.addString(value);

    client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );

    // Update local state immediately for switches
    setState(() {
      _componentStates[componentId] = {
        'value': value,
        'updatedAt': DateTime.now(),
      };
    });
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // Show alert to enable permission manually
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Location Permission"),
              content: Text("Please enable location permissions in settings."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      trackUserLocation();
    }
  }

  /// Track user's real-time location
  void trackUserLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        // distanceFilter: 2, // Update every 5 meters
      ),
    ).listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      if (destination != null) {
        fetchRoute(userLocation!, destination!);
      }
    }, onError: (error) {
      print("Location error: $error");
    });
  }



  double distance = 0.0;
  String timeEstimate = "";

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude) /
        1000; // Convert to km
  }

  String estimateTime(double distance) {
    double averageSpeed = 40; // Assume average speed of 40 km/h
    double time = distance / averageSpeed; // Time in hours
    int minutes = (time * 60).round();
    return "$minutes minutes";
  }

  /// Fetch route from OpenStreetMap
  Future<void> fetchRoute(LatLng start, LatLng end) async {
    String url =
        "https://router.project-osrm.org/route/v1/driving/${start
        .longitude},${start.latitude};${end.longitude},${end
        .latitude}?overview=full";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var points = decodePolyline(data['routes'][0]['geometry']);

        double calculatedDistance = calculateDistance(start, end);
        String estimatedTime = estimateTime(distance);

        setState(() {
          routePoints = points;
          distance = calculatedDistance;
          timeEstimate = estimatedTime;
        });

      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  /// Decode polyline for the route
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0,
        len = encoded.length;
    int lat = 0,
        lng = 0;

    while (index < len) {
      int shift = 0,
          result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }



  void _onDisconnected() {
    setState(() => _connectionStatus = 'Disconnected');
  }

  @override
  void dispose() {
    client?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deviceId} Control Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _connectToMqtt();
              _requestInitialState();
            },
          )
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_componentConfigs.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (!_initialStateLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading device state...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCopyCard(),
          _buildConnectionCard(),
          SizedBox(height: 20),
          ..._componentConfigs.entries.map((entry) =>
              Column(
                children: [
                  _buildComponentCard(entry.key, entry.value),
                  SizedBox(height: 20),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          _connectionStatus == 'Connected' ? Icons.wifi : Icons.wifi_off,
          color: _connectionStatus == 'Connected' ? Colors.green : Colors.red,
        ),
        title: Text('Status: $_connectionStatus'),
        subtitle: Text('Last update: $_lastUpdate'),
        trailing: _connectionStatus == 'Connected'
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.error, color: Colors.red),
      ),
    );
  }
  Widget _buildCopyCard() {
    return Card(
      child: Padding(padding: EdgeInsets.fromLTRB(15, 20, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'User ID: ${widget.deviceId}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Color(0xFFE75480)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Device ID: ${widget.deviceId}'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID copied to clipboard')),
                );
              },
            ),
          ],
        ),
      )
    );
  }

  Widget _buildComponentCard(String componentId, Map<String, dynamic> config) {
    final state = _componentStates[componentId] ?? {'value': '', 'updatedAt': DateTime.now()};
    final value = state['value'];
    final updatedAt = state['updatedAt'];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config['name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Type: ${config['type']} • V${config['virtualPin']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            _buildComponentWidget(componentId, config, value),
            SizedBox(height: 8),
            Text(
              'Last updated: ${DateFormat('HH:mm:ss').format(updatedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentWidget(String componentId, Map<String, dynamic> config, String value) {
    switch (config['type']) {
      case 'Switch':
        return _buildSwitchComponent(componentId, value);
      case 'LED':
        return _buildLEDIndicator(value);
      case 'Gauge':
        return _buildGaugeComponent(config, value);
      case 'LCD':
        return _buildLCDComponent(value);
      case 'Map':
        return _buildMapComponent(value);
      default:
        return Text('Unsupported component: ${config['type']}');
    }
  }

  Widget _buildSwitchComponent(String componentId, String value) {
    final isOn = value == '1';
    return SwitchListTile(
      title: Text(isOn ? 'ON' : 'OFF'),
      value: isOn,
      onChanged: (val) => _sendComponentCommand(componentId, val ? '1' : '0'),
      secondary: Icon(
        Icons.toggle_on,
        color: isOn ? Colors.blue : Colors.grey,
      ),
    );
  }

  Widget _buildLEDIndicator(String value) {
    final isOn = value == '1';
    return ListTile(
      leading: Icon(
        Icons.lightbulb,
        size: 40,
        color: isOn ? Colors.yellow : Colors.grey,
      ),
      title: Text('LED Status'),
      subtitle: Text(isOn ? 'Active' : 'Inactive'),
    );
  }

  Widget _buildGaugeComponent(Map<String, dynamic> config, String value) {
    final doubleValue = double.tryParse(value) ?? 0.0;
    final min = (config['rangeStart'] ?? 0).toDouble();
    final max = (config['rangeEnd'] ?? 200).toDouble();

    return SizedBox(
      height: 200,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: min,
            maximum: max,
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: min,
                endValue: min + (max - min) * 0.3,
                color: Colors.blue,
                label: 'Low',
              ),
              GaugeRange(
                startValue: min + (max - min) * 0.3,
                endValue: min + (max - min) * 0.7,
                color: Colors.green,
                label: 'Normal',
              ),
              GaugeRange(
                startValue: min + (max - min) * 0.7,
                endValue: max,
                color: Colors.red,
                label: 'High',
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: doubleValue,
                enableAnimation: true,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '${doubleValue.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                positionFactor: 0.5,
                angle: 90,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLCDComponent(String value) {
    // Split the value into lines (assuming newline characters separate rows)
    List<String> lines = value.split('\n');

    // Ensure we have exactly 4 lines (pad with empty strings if needed)
    while (lines.length < 4) {
      lines.add('');
    }
    lines = lines.sublist(0, 4);

    // Trim each line to 20 characters and pad with spaces if needed
    lines = lines.map((line) {
      if (line.length > 20) return line.substring(0, 20);
      return line.padRight(20);
    }).toList();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2F4F4F), // Dark slate gray background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LCD screen
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF0F380F), // Dark green LCD background
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: lines.map((line) {
                return Container(
                  height: 24, // Fixed height for each row
                  child: Text(
                    line,
                    style: TextStyle(
                      color: Color(0xFF8BAC0F), // LCD green text color
                      fontSize: 20,
                      fontFamily: 'Courier', // Monospace font
                      letterSpacing: 2,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // LCD frame decoration
          SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapComponent(String value) {
    final parts = value.split(',');
    final lat = double.tryParse(parts[0]) ?? 0.0;
    final lng = double.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0.0;

    // final lat = 9.1778;
    // final lng = 77.5351;


    setState(() {
      destination = LatLng(lat, lng);
    });
    if (userLocation != null) {
      fetchRoute(userLocation!, destination!);
    }

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          userLocation == null
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      child: Icon(Icons.my_location,
                          color: Colors.blue, size: 30),
                    ),
                  ],
                ),
              if (destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destination!,
                      child: Icon(Icons.location_on,
                          color: Colors.red, size: 30),
                    ),
                  ],
                ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),

          // Bottom Bar with Distance & Time Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Distance: ${distance.toStringAsFixed(2)} km",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Time: $timeEstimate",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                )


            ),
          ),
        ],
      ),

    );
  }
}