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
        final Map args = ModalRoute.of(context).settings.arguments;

        FreeRTOSDevice device = bluetoothStore.connectedDevices[args["uuid"]];

        if (device == null) {
            print("Unable to find connected device");
            Navigator.pop(context);
        }

        List<BluetoothService> services = bluetoothStore.services;

        // TODO: This used to work with AWS demo
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

        void _disconnect() async {            
            await bluetoothStore.disconnect(uuid: device.uuid);
            Navigator.pushNamed(context, "/bluetoothDevices");
        }

        return Observer(name: "BluetoothDevice",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: device != null ? Text("${device.name}") : Text(""),
                ),
                body: device != null ? Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        children: <Widget>[
                            Text("uuid: ${device.uuid}"),
                            Text("rssi: ${device.rssi}"),
                            Text("mtu: ${device.mtu}"),
                            Text("reconnect: ${device.reconnect}"),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                    OutlineButton(child: Text("services"), onPressed: () => bluetoothStore.getServices(device),),
                                    OutlineButton(child: Text("disconnect"), onPressed: _disconnect)
                                ],
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child: ListView.builder(
                                            itemCount: bluetoothStore.services.length,
                                            itemBuilder: (context, index) {
                                                return GestureDetector(
                                                        onTap: () => Navigator.pushNamed(context, "/bluetoothService", arguments: { "service": bluetoothStore.services[index]}),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                                Text("uuid: ${bluetoothStore.services[index].uuid}"),
                                                                Text("isPrimary: ${bluetoothStore.services[index].isPrimary}"),
                                                                Text("charecteristicSize: ${bluetoothStore.services[index].characteristics.length}")
                                                            ]
                                                        )
                                                    );
                                            }
                                    )
                                ),
                            ),
                        ],
                    )
                ) : Container()
            ),
        );
    }
}
