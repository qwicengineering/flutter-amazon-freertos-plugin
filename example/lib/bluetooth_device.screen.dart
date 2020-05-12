import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart";
import "package:flutter_mobx/flutter_mobx.dart";
import "package:provider/provider.dart";

import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

class BluetoothDeviceScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context)  {
        final bluetoothStore = Provider.of<BluetoothStore>(context);
        FreeRTOSDevice device = bluetoothStore.activeDevice;

        void _discoverServices() async {
            var services = await device.discoverServices();
            print(services);
        }

        final stateSubscription = device.observeState().listen((value) async {
            if (value == FreeRTOSDeviceState.CONNECTED) {
                // Need to wait for 3 seconds due to Amazon GATT server
                // demo requiring extra steps to get fully connected
                // as it required a user verification
                Timer(Duration(seconds: 3), () async => print(await device.discoverServices()));
            }
        });

        void _writeToCharacteristic(int value) async {
            // start counter = 0
            // stop counter = 1
            // reset counter = 2
            var services = await device.discoverServices();
            var characteristics = services.firstWhere((service) => service.uuid.toString().toLowerCase() == bluetoothStore.demoService).characteristics;
            if (characteristics.length < 0) {
                print("No characteristics found");
                return;
            }

            BluetoothCharacteristic customChar = characteristics.firstWhere((c) => c.uuid.toString().toLowerCase() == bluetoothStore.demoWrite);
            customChar.writeValue(Uint8List.fromList([value]));
        }

        void _readCharacteristic() async {
            var services = await device.discoverServices();
            var characteristics = services.firstWhere((service) => service.uuid.toString().toLowerCase() == bluetoothStore.demoService).characteristics;
            if (characteristics.length < 0) {
                print("No characteristics found");
                return;
            }

            BluetoothCharacteristic customChar = characteristics.firstWhere((c) => c.uuid.toString().toLowerCase() == bluetoothStore.demoRead);
            await customChar.readValue();
            print(decodeToInt(customChar.value));
        }

        void _disconnect() async {
            stateSubscription.cancel();
            device.disconnect();
            Navigator.popAndPushNamed(context, "/bluetoothDevices");
        }
        
        return Observer(name: "BluetoothDevice",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("${device.name}"),
                ),
                body: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Text("uuid: ${device.uuid}"),
                            Text("rssi: ${device.rssi}"),
                            Text("mtu: ${device.mtu}"),
                            Text("reconnect: ${device.reconnect}"),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                    OutlineButton(child: Text("Start"), onPressed: () => _writeToCharacteristic(0),),
                                    OutlineButton(child: Text("Stop"), onPressed: () => _writeToCharacteristic(1),),
                                    OutlineButton(child: Text("Reset"), onPressed: () => _writeToCharacteristic(2),),
                                    OutlineButton(child: Text("Read"), onPressed: _readCharacteristic,)
                                ],
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                    OutlineButton(child: Text("services"), onPressed: _discoverServices,),
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
