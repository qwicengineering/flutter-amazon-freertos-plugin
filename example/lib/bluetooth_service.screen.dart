import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import "package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

class BluetoothServiceScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final bluetoothStore = Provider.of<BluetoothStore>(context);
        final Map args = ModalRoute.of(context).settings.arguments;

        BluetoothService service = args["service"];

        if (service == null) {
            print("Empty service argument");
            Navigator.pop(context);
        }

        FreeRTOSDevice device = bluetoothStore.connectedDevices[service.deviceUUID];
        List characteristics = service.characteristics;

         _readCharacteristic(BluetoothCharacteristic characteristic) async {            
            var test = await characteristic.readValue();                 
            // TODO: needs to be decoded
            return test;
        }

        return Observer(name: "BluetoothScreen",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("${device.name}")
                ),
                body: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        children: <Widget>[
                            Text("uuid: ${device.uuid}"),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    child: ListView.builder(
                                            itemCount: characteristics.length,
                                            itemBuilder: (context, index) {
                                                var value = FutureBuilder<Object>(
                                                    future: _readCharacteristic(characteristics[index]),
                                                    builder: (context, AsyncSnapshot<Object> snapshot) {
                                                        if (snapshot.hasData) {                                                            
                                                            return Text("value: ${snapshot.data.toString()}");
                                                        } else {
                                                            return CircularProgressIndicator();
                                                        }
                                                    }
                                                );
                                                return Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Container(                                                        
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                                Text("Id: ${characteristics[index].uuid}"),
                                                                Text("isNotifying: ${characteristics[index].isNotifying}"),
                                                                value,
                                                                OutlineButton(child: Text("Log value"), onPressed: () => print(_readCharacteristic(characteristics[index]))),                                                                
                                                            ]
                                                        )
                                                    ),
                                                );
                                            }
                                    )
                                ),
                            ),
                        ],
                    )
                ),
            ),
        );
    }
}
