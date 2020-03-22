import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;

  @override
  void initState() {
    super.initState();
    getBluetoothState();

    // register callback for bluetoothStateChange
    amazonFreeRTOSPlugin.registerBluetoothStateChangeCallback((bluetoothState) {
      if(!mounted) return;

      setState(() {
        _bluetoothState = bluetoothState;
      });
    });
  }

  @override
  void dispose() {
    amazonFreeRTOSPlugin.registerBluetoothStateChangeCallback(null);
    super.dispose();
  }

  Future<void> getBluetoothState() async {
    BluetoothState bluetoothState;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bluetoothState = await amazonFreeRTOSPlugin.bluetoothState;
    } on PlatformException catch (e, trace) {
      print("failed to get bluetooth state");
      print(e);
      print(trace);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _bluetoothState = bluetoothState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Amazon FreeRTOS Example"),
        ),
        body: Center(
          child: Text('Bluetooth state: $_bluetoothState\n'),
        ),
      ),
    );
  }
}
