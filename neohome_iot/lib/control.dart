import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';



class ControlPanel extends StatefulWidget {
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  MqttServerClient? client;
  String _connectionStatus = 'Disconnected';
  bool _ledStatus = false;
  double _temperature = 0.0;
  String _lastUpdate = 'Never';
  final String _mqttServer = '18.175.253.73'; // Replace with your domain
  final String _clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

  // Topics
  final String _ledCommandTopic = 'esp32/led/command';
  final String _ledStatusTopic = 'esp32/led/status';
  final String _tempTopic = 'esp32/temperature';
  final String _stateRequestTopic = 'esp32/state/request';
  final String _stateResponseTopic = 'esp32/state/response';

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    setState(() => _connectionStatus = 'Connecting...');

    client = MqttServerClient(_mqttServer, _clientId);
    client!.port = 1883; // Use 8883 for SSL

    // Set MQTT protocol version
    client!.setProtocolV311();

    // Connection options
    client!.keepAlivePeriod = 30;
    client!.onDisconnected = _onDisconnected;
    client!.logging(on: false);

    // Connect with try-catch
    try {
      await client!.connect();
    } catch (e) {
      setState(() => _connectionStatus = 'Connection failed: $e');
      return;
    }

    // Check connection
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _setupMqttSubscriptions();
      _requestDeviceState();
      setState(() => _connectionStatus = 'Connected');
    } else {
      setState(() => _connectionStatus = 'Connection failed');
    }
  }

  void _setupMqttSubscriptions() {
    // Subscribe to topics with QoS 1 (At least once delivery)
    client!.subscribe(_ledStatusTopic, MqttQos.atLeastOnce);
    client!.subscribe(_tempTopic, MqttQos.atLeastOnce);
    client!.subscribe(_stateResponseTopic, MqttQos.atLeastOnce);

    // Listen for messages
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);


        setState(() {
          _lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());

          switch (message.topic) {
            case 'esp32/led/status':
              _ledStatus = payload == '1';
              break;
            case 'esp32/temperature':
              _temperature = double.tryParse(payload) ?? _temperature;
              break;
            case 'esp32/state/response':
              _processStateResponse(payload);
              break;
          }
        });
      }
    });
  }

  void _processStateResponse(String payload) {
    final parts = payload.split(',');
    if (parts.length == 2) {
      _temperature = double.tryParse(parts[0]) ?? _temperature;
      _ledStatus = parts[1] == '1';
    }
  }

  void _requestDeviceState() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('get_state');
    client!.publishMessage(
      _stateRequestTopic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  void _toggleLed() {
    final newState = !_ledStatus;
    final builder = MqttClientPayloadBuilder();
    builder.addString(newState ? '1' : '0');

    // Publish with retain=true so new subscribers get last state
    client!.publishMessage(
      _ledCommandTopic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );

    setState(() => _ledStatus = newState);
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
        title: Text('ESP32 Control Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _connectToMqtt,
            tooltip: 'Reconnect',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConnectionCard(),
            SizedBox(height: 20),
            _buildTemperatureCard(),
            SizedBox(height: 20),
            _buildLedControlCard(),
          ],
        ),
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

  Widget _buildTemperatureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Temperature',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 50,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 15, color: Colors.blue, label: 'Cold'),
                      GaugeRange(startValue: 15, endValue: 35, color: Colors.green, label: 'Normal'),
                      GaugeRange(startValue: 35, endValue: 50, color: Colors.red, label: 'Hot'),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(value: _temperature, enableAnimation: true)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${_temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        positionFactor: 0.5,
                        angle: 90,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'LED Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(_ledStatus ? 'LED ON' : 'LED OFF'),
              value: _ledStatus,
              onChanged: (value) => _toggleLed(),
              secondary: Icon(
                Icons.lightbulb,
                color: _ledStatus ? Colors.yellow : Colors.grey,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}