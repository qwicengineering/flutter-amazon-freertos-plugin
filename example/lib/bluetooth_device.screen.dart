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
        List<BluetoothService> services = bluetoothStore.services;

        void _discoverServices() {            
            print(services);
        }

        void _writeToCharacteristic(int value) {
            // start counter = 0
            // stop counter = 1
            // reset counter = 2
            // var services = await device.discoverServices();
            var characteristics = services.firstWhere((service) => service.uuid.toString().toLowerCase() == bluetoothStore.demoService).characteristics;
            if (characteristics.length < 0) {
                print("No characteristics found");
                return;
            }

            BluetoothCharacteristic customChar = characteristics.firstWhere((c) => c.uuid.toString().toLowerCase() == bluetoothStore.demoWrite);
            customChar.writeValue(Uint8List.fromList([value]));
        }

        void _readCharacteristic() async {
            // var services = await device.discoverServices();
            var characteristics = services.firstWhere((service) => service.uuid.toString().toLowerCase() == bluetoothStore.demoService).characteristics;
            if (characteristics.length < 0) {
                print("No characteristics found");
                return;
            }

            BluetoothCharacteristic customChar = characteristics.firstWhere((c) => c.uuid.toString().toLowerCase() == bluetoothStore.demoRead);
            await customChar.readValue();
            print(decodeToInt(customChar.value));
        }

        void _disconnect() {
            // stateSubscription.cancel();
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
