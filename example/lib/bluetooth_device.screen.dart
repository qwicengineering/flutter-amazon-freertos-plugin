import 'package:flutter/material.dart';
import 'package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

class BluetoothDeviceScreen extends StatelessWidget {

    @override
    Widget build(BuildContext context)  {
        final bluetoothStore = Provider.of<BluetoothStore>(context);
        FreeRTOSDevice device = bluetoothStore.activeDevice;

        final stateSubscription = device.observeDeviceState().listen((value) {
            print(value);
        });

        void _disconnect() async {
            stateSubscription.cancel();
            device.disconnect();
            Navigator.popAndPushNamed(context, "/bluetoothDevices");
        }
        
        return Observer(name: "BluetoothDevice",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("Bluetooth Device"),
                ),
                body: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Text("uuid: ${device.uuid}"),
                            Text("name: ${device.name}"),
                            Text("rssi: ${device.rssi}"),
                            Text("mtu: ${device.mtu}"),
                            Column(
                                children: <Widget>[
                                    OutlineButton(child: Text("disconnect"), onPressed: _disconnect)
                                ],
                            )
                        ],
                    )
                ),
            ),
        );
    }
}
