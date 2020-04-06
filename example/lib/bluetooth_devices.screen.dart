import "dart:async";

import "package:flutter/material.dart";
import 'package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart';
import "package:flutter_amazon_freertos_plugin_example/stores/cognito/cognito.store.dart";
import 'package:flutter_mobx/flutter_mobx.dart';
import "package:provider/provider.dart";

class BluetoothDevicesScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        Timer devicesNearbyTimer;
        final cognitoStore = Provider.of<CognitoStore>(context);
        final bluetoothStore = Provider.of<BluetoothStore>(context); 

        // TODO: I'm not sure if this is the best place to initialize
        bluetoothStore.initialize();

        Future<void> _onPressedSignOut() async {
            try {
                await cognitoStore.signOut();
                Navigator.popAndPushNamed(context, "/");
            } catch (e) {
                print("Error: Unable to sign out _onPressedSignOut");
                print(e);
            }
        }

        Future<void> _stopScanning() async {
            try {
                await bluetoothStore.stopScanning();
                
                if(!devicesNearbyTimer.isActive) return;
                devicesNearbyTimer.cancel();
            } catch (e) {
                print("Error: Failed to _stopScanning()");
                print(e);
            }
        }

        void _getDevicesNearby() {
            // Nearby devices list are usually cached. 
            // If there is a new device discovered nearby, it is added to the list
            // automatically. This is not the the case if the device that was previously
            // discovered and in list turned off (for any reason). It does not get removed
            // from list automatically.
            // rescanForDevices() freshes the device list from the platform side. 

            devicesNearbyTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
                await bluetoothStore.getDevicesNearby();
            });
        }

        Future<void> _startScanning() async {
            await bluetoothStore.startScanning();
            _getDevicesNearby();
        }

        print("BLE devices nearby");
        print("${bluetoothStore.devicesNearby}");

        return Observer(name: "BluetoothDevicesScreen",
            builder: (_) =>Scaffold(
            appBar: AppBar(
                title: Text("BLE Devices"),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.refresh),
                        tooltip: "Rescan for devices",
                        onPressed: bluetoothStore.rescan,
                    )
                ],
            ),
            body: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                    children: <Widget>[
                        Text("Bluetooth state: ${bluetoothStore.bluetoothState}\n"),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                                OutlineButton(child: Text("Start Scan"), onPressed: _startScanning),
                                OutlineButton(child: Text("Stop Scan"), onPressed: _stopScanning),
                                OutlineButton(child: Text("Sign out"), onPressed: _onPressedSignOut),
                            ]
                        )
                    ],
                ),
            ),
        ),
        );
    }
}
