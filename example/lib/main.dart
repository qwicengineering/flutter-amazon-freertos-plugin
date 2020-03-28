import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
}
final channel = MethodChannel("nl.qwic.plugins.flutter_amazon_freertos_plugin");

class _MyAppState extends State<MyApp> {
    BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
    FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;
    List<FreeRTOSDevice> _devicesFound = [];
    Timer discoveredDevicesTimer;

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

    // Future<void> discoverDevices() async {
    //     amazonFreeRTOSPlugin.discoverDevices.listen((device) {
    //         print(device);
    //     });
    // }

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

    void getDiscoveredDevices() {
        // Discovered devices are usually cached. 
        // If there is a new device, it is added to the list.
        // However, a device is not removed automatically.
        // Use rescanForDevices() to refresh the discoveredDevice list
        discoveredDevicesTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
            var devices = await amazonFreeRTOSPlugin.discoveredDevices;
            setState(() {
                _devicesFound = devices;
            });
        });
    }

    Future<void> startScanning() async {
        try {
            await amazonFreeRTOSPlugin.startScanForDevices();
            getDiscoveredDevices();
        } on PlatformException catch (e) {
            print("Failed to start scan");
            print(e);
        }
    }

    Future<void> stopScanning() async {
        try {
            amazonFreeRTOSPlugin.stopScanForDevices();
            discoveredDevicesTimer.cancel();
            print("Stop scaning for devices");
        } on PlatformException catch (e) {
            print("Failed to stop scan");
            print(e);
        }
    }

    Future<void> rescan() async {
        try {
            amazonFreeRTOSPlugin.rescanForDevices();
        } on PlatformException catch (e) {
            print("Failed to rescan");
            print(e);
        }
    }

    @override
    Widget build(BuildContext context) {
        print(_devicesFound);
        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                title: const Text("Amazon FreeRTOS BLE"),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.refresh),
                        tooltip: "Rescan for devices",
                        onPressed: rescan,
                    )],
                ),
                body: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        children: <Widget>[
                            Text('Bluetooth state: $_bluetoothState\n'),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                                OutlineButton(child: Text("Start Scan"), onPressed: startScanning),
                                OutlineButton(child: Text("Stop Scan"), onPressed: stopScanning),
                            ])
                        ],
                    ),
                ),
            ),
        );
    }
}
