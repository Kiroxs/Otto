import 'dart:convert';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class conexionVista extends StatefulWidget {
  const conexionVista({super.key});

  @override
  State<conexionVista> createState() => _conexionVistaState();
}

class _conexionVistaState extends State<conexionVista> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  int _deviceStatus = Device.disconnected;
  Uint8List _data = Uint8List(0);
  String _platformVersion = 'Unknown';
  TextEditingController _commandController = TextEditingController();
  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void initState() {
    super.initState();

    _requestPermission();
    initPlatformState();
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((event) {
      setState(() {
        _deviceStatus = event;
      });
    });
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      setState(() {
        _data = Uint8List.fromList([..._data, ...event]);
      });
    });
  }

  Future<void> _getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    setState(() {
      _devices = res;
    });
  }

  Future<void> _scan() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      await _bluetoothClassicPlugin.startScan();
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (event) {
          setState(() {
            _discoveredDevices = [..._discoveredDevices, event];
          });
        },
      );
      setState(() {
        _scanning = true;
      });
    }
  }

  Future<void> connectToDevice(
      String deviceAddress, BuildContext context) async {
    try {
      await _bluetoothClassicPlugin.connect(
          "98:D3:71:FE:5A:9A", "00001101-0000-1000-8000-00805f9b34fb");
      print("Connected to the device");
      mostrarMensaje(context, "Connected to the device");
    } on PlatformException catch (e) {
      print("Failed to connect: ${e.message}");
      mostrarMensaje(context, "Failed to connect: ${e.message}");
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> sendMoveCommand(String command) async {

    try {
      await _bluetoothClassicPlugin.write(command);
     
      print("Command sent successfully");
      mostrarMensaje(context, "Command sent successfully");
    } catch (e) {
      print("Failed to send command: $e");
      mostrarMensaje(context, "Failed to send command: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Device status is $_deviceStatus"),
              
              Text("Received data: ${String.fromCharCodes(_data)}"),
              TextButton(
                onPressed: () {
                  connectToDevice("deviceAddress", context);
                },
                child: Text("conectar"),
              ),
              TextField(
                controller : _commandController,
                decoration: InputDecoration(
                  hintText: "Escribe el comando",
                ),
              ),
              TextButton(
                onPressed: () {
                  sendMoveCommand(_commandController.text);
                },
                child: Text("COMANDO SIMPLE"),
              ),
               Text("Received data: ${String.fromCharCodes(_data)}"),
              /* Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  border: Border.all(
                    color: Color(0xff93479b),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Color(0xff93479b),
                  ),
                ),
              ),
              SizedBox(height: 26),
              Text(
                "CONECTAR",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 26), */
            ],
          ),
        ),
      ),
    );
  }
}
