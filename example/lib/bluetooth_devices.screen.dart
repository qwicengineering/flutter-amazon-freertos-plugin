import "dart:async";
import "package:flutter_mobx/flutter_mobx.dart";
import "package:flutter/material.dart";
import "package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart";
import "package:flutter_amazon_freertos_plugin_example/stores/cognito/cognito.store.dart";
import "package:provider/provider.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

class BluetoothDevicesScreen extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
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
            } catch (e) {
                print("Error: Failed to _stopScanning()");
                print(e);
            }
        }

        Widget _buildDeviceContainer(BuildContext context, int index) {
            FreeRTOSDevice device = bluetoothStore.devicesNearby[index];

            return InkWell(
                onTap: () async {
                    var isConnected = await device.isConnected;
                    if (!isConnected) {
                        await bluetoothStore.connectDevice(device);
                    }

                    Navigator.pushNamed(context, "/bluetoothDevice");
                },
                splashColor: Colors.amberAccent,
                child: Container(
                    height: 50,
                    color: Colors.blue,
                    child: Center(child: Text("${device.name}"))
                )
            );
        }

        return Observer(name: "BluetoothDevices",
            builder: (_) => Scaffold(
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
                                children: <Widget>[
                                    OutlineButton(child: Text("Start"), onPressed: bluetoothStore.startScanning),
                                    OutlineButton(child: Text("Devices"), onPressed: bluetoothStore.getDevicesNearby),
                                    OutlineButton(child: Text("Stop"), onPressed: _stopScanning),
                                    OutlineButton(child: Text("Sign out"), onPressed: _onPressedSignOut),
                                ]
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: ListView.builder(
                                        padding: EdgeInsets.all(8),
                                        itemCount: bluetoothStore.devicesNearby.length,
                                        itemBuilder: _buildDeviceContainer,
                                    ),
                                ),
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}
