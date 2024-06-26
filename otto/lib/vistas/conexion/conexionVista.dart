import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:otto/vistas/canciones/cancionesVista.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class conexionVista extends StatefulWidget {
  const conexionVista({super.key});

  @override
  State<conexionVista> createState() => _conexionVistaState();
}

class _conexionVistaState extends State<conexionVista> {
  final _flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  final Set<BluetoothDevice> _scanResults = {};
  StreamSubscription? _scanSubscription;
  TextEditingController _controller = TextEditingController();
  bool _isScanning = false;
  StreamSubscription? _scanningStateSubscription;
  BluetoothConnection? connection;
  bool isButtonEnabled = true;
  late bool prueba;
  List<String> pasos = [
    "MOVE 1 2000",
    "MOVE 1 2000",
    "MOVE 2 2000",
    "MOVE 2 2000",
    "MOVE 18 2000",
    "MOVE 4 2000",
    "MOVE 9 2000 100"
  ];
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _requestPermission();
  }

  Future<void> initPlatformState() async {
    BluetoothAdapterState adapterState = _adapterState;

    try {
      adapterState = await _flutterBlueClassicPlugin.adapterStateNow;
      _adapterStateSubscription =
          _flutterBlueClassicPlugin.adapterState.listen((current) {
        if (mounted) setState(() => _adapterState = current);
      });
      _scanSubscription =
          _flutterBlueClassicPlugin.scanResults.listen((device) {
        if (mounted) setState(() => _scanResults.add(device));
      });
      _scanningStateSubscription =
          _flutterBlueClassicPlugin.isScanning.listen((isScanning) {
        if (mounted) setState(() => _isScanning = isScanning);
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (!mounted) return;

    setState(() {
      _adapterState = adapterState;
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanningStateSubscription?.cancel();

    super.dispose();
  }

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Container(
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
                
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          
                          setState(() {
                            isButtonEnabled = false; // Deshabilita el botón
                          });

                          try {
                            var connection = await _flutterBlueClassicPlugin.connect("98:D3:71:FE:5A:9A");
                            if (!this.context.mounted) return;
                            if (connection != null && connection.isConnected) {
                              await Provider.of<CancionesModel>(context, listen: false).setConnection(connection);
                              Provider.of<CancionesModel>(context, listen: true).setConnection(connection);
                              ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text("Connected to device")));
                            } else {
                              ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text("Error connecting to device")));
                            }
                          } catch (e) {
                            if (kDebugMode) print(e);
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text("Error connecting to device")));
                          } finally {
                            setState(() {
                              isButtonEnabled = true; // Habilita el botón nuevamente
                            });
                          }
                        }
                      : null,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 50,
                      color: Color(0xff93479b),
                    ),
                  ),
                ),
              ),
              Text("Conectar"),
            ],
          ),
        ),
      ),
    );
  }
}
