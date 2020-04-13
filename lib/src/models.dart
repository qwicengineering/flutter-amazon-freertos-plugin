part of flutter_amazon_freertos_plugin;

enum BluetoothState {
    POWERED_OFF,
    POWERED_ON,
    RESETTING,
    UNAUTHORIZED,
    UNSUPPORTED,
    UNKNOWN,
}

enum FreeRTOSDeviceState {
    CONNECTED,
    CONNECTING,
    DISCONNECTED,
    DISCONNECTING
}

class FreeRTOSDevice {
    final String uuid;
    final String name;
    final bool reconnect;
    final int rssi;
    final String certificateId;
    final String brokerEndpoint;
    final int mtu;

    final _channel = FlutterAmazonFreeRTOSPlugin.instance.channel;

    FreeRTOSDevice.fromJson(Map jsonData) 
        :   uuid = jsonData["uuid"],
            name = jsonData["name"],
            reconnect = jsonData["reconnect"] == true,
            rssi = jsonData["rssi"],
            certificateId = jsonData["certificateId"],
            brokerEndpoint = jsonData["brokerEndpoint"],
            mtu = jsonData["mtu"];

    Future<void> connect() async {
        await _channel.invokeMethod("connectToDeviceId", { "deviceUUID": uuid });
    }

    Future<void> disconnect() async {
        await _channel.invokeMethod("disconnectFromDeviceId", { "deviceUUID": uuid });
    }

    Future<List> discoverServices() async {
        var services = await _channel.invokeListMethod("listServicesForDeviceId", { "deviceUUID": uuid });
        return List<BluetoothService>.from(
            services.map((service){
                return BluetoothService.fromJson(service);
            })
        );
    }

    Future<void> discoverCharacteristics() async {
        await _channel.invokeListMethod("discoverCharactersitics");
    }

    Stream<FreeRTOSDeviceState> observeDeviceState() {
        return PluginScaffold.createStream(_channel, "deviceState", uuid)
                .map((value) => FreeRTOSDeviceState.values[value]);
    }

    Future<bool> get isConnected async {
        var state = await _channel.invokeMethod("deviceState", { "deviceUUID": uuid });
        return FreeRTOSDeviceState.CONNECTED == FreeRTOSDeviceState.values[state];
    }
}

class BluetoothService {
    final String uuid;
    final bool isPrimary;
    final List characteristics;

    BluetoothService.fromJson(Map jsonData)
        :   uuid = jsonData["uuid"],
            isPrimary = jsonData["isPrimary"],
            characteristics = jsonData["characteristics"].map((c) =>  BluetoothCharacteristic.fromJson(c) ).toList();

}

class BluetoothCharacteristic {
    final String uuid;
    final bool isNotifying;
    final List<int> value;
    final String serviceId;
    final BluetoothCharacteristicProperties properties;

    BluetoothCharacteristic.fromJson(Map jsonData) 
        :   uuid = jsonData["uuid"],
            isNotifying = jsonData["isNotifying"],
            value = jsonData["value"],
            properties = BluetoothCharacteristicProperties.fromJson(jsonData["properties"]),
            serviceId = jsonData["serviceId"];
}

class BluetoothCharacteristicProperties {
    final bool isReadable;
    final bool isWritable;
    final bool isWritableWithoutResponse;
    final bool isNotifying;
    final bool isIndicatable;
    final bool allowsSignedWrites;
    final bool hasExtendedProperties;
    final bool notifyEncryptionRequired;
    final bool indicateEncryptionRequired;

    BluetoothCharacteristicProperties.fromJson(Map jsonData)
        :   isReadable = jsonData["isReadable"],
            isWritable = jsonData["isWritable"],
            isWritableWithoutResponse = jsonData["isWritableWithoutResponse"],
            isNotifying = jsonData["isNotifying"],
            isIndicatable = jsonData["isIndicatable"],
            allowsSignedWrites = jsonData["allowsSignedWrites"],
            hasExtendedProperties = jsonData["hasExtendedProperties"],
            notifyEncryptionRequired = jsonData["notifyEncryptionRequired"],
            indicateEncryptionRequired = jsonData["indicateEncryptionRequired"];
}
