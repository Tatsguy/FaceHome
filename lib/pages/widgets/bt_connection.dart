import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class BtConnection extends StatefulWidget {
  const BtConnection({Key? key}) : super(key: key);

  @override
  State<BtConnection> createState() => _BtConnectionState();
}

class _BtConnectionState extends State<BtConnection> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  int times = 0;
  String temperature = 'N/A';
  StreamSubscription<Uint8List>? _subscription;

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _receiveData() {
    _subscription = _connection?.input?.listen((Uint8List data) {
      String receivedData = utf8.decode(data);
      if (receivedData.contains("TEMP:")) {
        setState(() {
          temperature = receivedData.split(":")[1].substring(0, 5);
        });
      }
    });
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void _showDevices() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Dispositivos Bluetooth Disponibles"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                  title: Text(_devices[index].name ?? 'Sin nombre'),
                  subtitle: Text(_devices[index].address),
                  onTap: () async {
                    setState(() => _isConnecting = true);
                    await BluetoothConnection.toAddress(_devices[index].address)
                        .then((connection) {
                      _connection = connection;
                      setState(() {
                        _deviceConnected = _devices[index];
                        _isConnecting = false;
                      });
                      _receiveData();
                      Navigator.of(context).pop();
                    });
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _requestPermission();

    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
      if (_bluetoothState) {
        _getDevices();
      }
    });

    _bluetooth.onStateChanged().listen((state) {
      if (state == BluetoothState.STATE_OFF) {
        setState(() => _bluetoothState = false);
      } else if (state == BluetoothState.STATE_ON) {
        setState(() => _bluetoothState = true);
        _getDevices();
      }
    });
  }

  void sendMessage(String message) {
    if (_connection != null) {
      _connection!.output.add(Uint8List.fromList(utf8.encode(message + "\n")));
    }
  }

  bool isOn = false;

  void toggleLed() {
    setState(() {
      isOn = !isOn;
      !isOn ? sendMessage("LED_OFF") : sendMessage("LED_ON");
    });
  }

  bool isOpen = false;

  void toggleDoor() {
    setState(() {
      isOpen = !isOpen;
      !isOpen
          ? sendMessage("MOTOR_BACKWARD1000")
          : sendMessage("MOTOR_FORWARD1000");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SensorControlCard(
              title: 'Control LED',
              icon: Icons.lightbulb_outline,
              onPressed: () {
                toggleLed();
              },
            ),
            SensorDisplayCard(
              title: 'Temperatura',
              value:
                  '$temperature °C', // Aquí debes obtener el valor real del sensor
              icon: Icons.thermostat_outlined,
            )
          ],
        ),
        Column(
          children: [
            SensorControlCard(
              title: 'Motor Puerta',
              icon: Icons.lock_outline,
              onPressed: () {
                toggleDoor();
              },
            ),
            Expanded(
                child: ElevatedButton(
              onPressed: _bluetoothState ? _showDevices : null,
              child: Icon(
                Icons.bluetooth,
                size: 100,
              ),
            ))
          ],
        )
      ],
    ));
  }
}

class SensorControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  SensorControlCard(
      {required this.title, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 100),
              SizedBox(height: 8),
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    ));
  }
}

class SensorDisplayCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  SensorDisplayCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ));
  }
}
