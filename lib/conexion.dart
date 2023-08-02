import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnectPage extends StatefulWidget {
  @override
  _BluetoothConnectPageState createState() => _BluetoothConnectPageState();
}

class _BluetoothConnectPageState extends State<BluetoothConnectPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results.map((r) => r.device).toList();
      });
    });

    flutterBlue.startScan();
  }

  void _stopScan() {
    flutterBlue.stopScan();
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // Realiza la comunicación Bluetooth con el dispositivo conectado
    // Puedes usar device.discoverServices() para descubrir los servicios disponibles
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar por Bluetooth'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name),
            subtitle: Text(devices[index].id.toString()),
            onTap: () => _connectToDevice(devices[index]),
          );
        },
      ),
    );
  }
}
