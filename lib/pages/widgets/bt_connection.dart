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

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      if (String.fromCharCodes(event) == "p") {
        setState(() => times = times + 1);
      }
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
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

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SensorControlCard(
              title: 'Control LED',
              icon: Icons.lightbulb_outline,
              onPressed: () {
                // Lógica para controlar el LED
              },
            ),
            SensorDisplayCard(
              title: 'Temperatura',
              value: '25°C', // Aquí debes obtener el valor real del sensor
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
                // Lógica para controlar el motor
              },
            ),
            ElevatedButton(
                onPressed: _bluetoothState ? _showDevices : null,
                child: Icon(
                  Icons.bluetooth,
                  size: 100,
                ),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16.0)))
          ],
        ),
        if (_deviceConnected != null)
          Text('Conectado a: ${_deviceConnected?.name}'),
        if (_isConnecting) CircularProgressIndicator(),
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
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48),
              SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 48),
            SizedBox(height: 8),
            Text(title),
            Text(value),
          ],
        ),
      ),
    );
  }
}
