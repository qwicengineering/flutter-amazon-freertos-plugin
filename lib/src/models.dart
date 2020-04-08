part of flutter_amazon_freertos_plugin;

enum BluetoothState {
    POWERED_OFF,
    POWERED_ON,
    RESETTING,
    UNAUTHORIZED,
    UNSUPPORTED,
    UNKNOWN,
}

enum DeviceState {
    CONNECTED,
    CONNECTING,
    DISCONNECTED,
    DISCONNECTING
}

enum BluetoothCharacteristicProperty {
    BROADCAST,
    READ,
    WRITE_WITHOUT_RESPONSE,
    WRITE,
    NOTIFY,
    INDICATE,
    AUTHENTICATED_SIGNED_WRITES,
    EXTENEDED_PROPERTIES,
    NOTIFY_ENCRYPTION_REQUIRED,
    INDICATE_ENCRYPTION_REQUIRED
}

class FreeRTOSDevice {
    final String id;
    final String name;
    final DeviceState state;
    final bool reconnect;
    final int rssi;
    final String certificateId;
    final String brokerEndpoint;
    final int mtu;

    FreeRTOSDevice.fromJson(Map jsonData) 
        :   id = jsonData["id"],
            name = jsonData["name"],
            state = DeviceState.values[jsonData["state"]],
            reconnect = jsonData["reconnect"] == true,
            rssi = jsonData["rssi"],
            certificateId = jsonData["certificateId"],
            brokerEndpoint = jsonData["brokerEndpoint"],
            mtu = jsonData["mtu"];

    Future<void> connect() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeMethod("connectToDeviceId", {"id": id});
    }

    Future<void> disconnect() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeMethod("disconnectFromDeviceId", {"id": id});
    }

    Future<List> discoverServices() async {
        var services = await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeListMethod("listServicesForDeviceId", {"id": id});
        return List<BluetoothService>.from(
            services.map((service){
                return BluetoothService.fromJson(service);
            })
        );
    }

    Future<void> discoverCharacteristics() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeListMethod("discoverCharactersitics");
    }
}


class BluetoothService {
    final String id;
    final bool isPrimary;
    final List characteristics;

    BluetoothService.fromJson(Map jsonData)
        :   id = jsonData["id"],
            isPrimary = jsonData["isPrimary"],
            characteristics = jsonData["characteristics"].map((c) =>  BluetoothCharacteristic.fromJson(c) ).toList();
}

class BluetoothCharacteristic {
    final String id;
    final bool isNotifying;
    final List<int> value;
    final String serviceId;

    BluetoothCharacteristic.fromJson(Map jsonData) 
        :   id = jsonData["id"],
            isNotifying = jsonData["isNotifying"],
            value = jsonData["value"],
            serviceId = jsonData["serviceId"];

}
