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
    CONNECTED, // on Android this means Bonded and Connected
    CONNECTING,
    DISCONNECTED,
    DISCONNECTING,
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

    Future<List<BluetoothService>> _discoveredServices;

    FreeRTOSDevice.fromJson(Map jsonData)
        :   uuid = jsonData["uuid"],
            name = jsonData["name"],
            reconnect = jsonData["reconnect"] == true,
            rssi = jsonData["rssi"],
            certificateId = jsonData["certificateId"],
            brokerEndpoint = jsonData["brokerEndpoint"],
            mtu = jsonData["mtu"];

    // It need to throw a new exception to be catched where this method is called from
    Future<void> connect({ bool reconnect = true }) async {
        try {
            await _channel.invokeMethod("connectToDeviceId", { "deviceUUID": uuid, "reconect": reconnect });
        } on PlatformException catch(e) {
            throw new Exception(e);
        }
    }

    Future<void> disconnect() async {
        await _channel.invokeMethod("disconnectFromDeviceId", { "deviceUUID": uuid });
    }

    // Will not be able to retreive custom services on iOS
    // until periperal.discoverServices() is called again
    // on device connect.
    Future<void> discoverServices({List<String> serviceUUIDS}) async {
        // invoke discoverServices();
        // retrieve them and return them
        _discoveredServices = PluginScaffold.createStream(_channel, "discoverServices", { "deviceUUID": uuid })
                        .map((service) {                            
                            return BluetoothService.fromJson(service);
                        }).toList();
        await _channel.invokeListMethod("discoverServices", { "deviceUUID": uuid, "serviceUUIDS": serviceUUIDS });
    }

    Future<List<BluetoothService>> services() => _discoveredServices;

    Future<void> discoverCharacteristics() async {
        await _channel.invokeListMethod("discoverCharactersitics");
    }

    Stream<FreeRTOSDeviceState> observeState() {
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
    final String deviceUUID;
    final bool isPrimary;
    final List characteristics;

    BluetoothService.fromJson(Map jsonData)
        :   uuid = jsonData["uuid"],
            isPrimary = jsonData["isPrimary"],
            deviceUUID = jsonData["deviceUUID"],
            characteristics = jsonData["characteristics"].map((c) =>  BluetoothCharacteristic.fromJson(c) ).toList();
}

class BluetoothCharacteristic {
    final String uuid;
    final String serviceUUID;
    final String deviceUUID;
    final bool isNotifying;
    final Uint8List value;
    final BluetoothCharacteristicProperties properties;

    final _channel = FlutterAmazonFreeRTOSPlugin.instance.channel;

    BluetoothCharacteristic.fromJson(Map jsonData)
        :   uuid = jsonData["uuid"],
            serviceUUID = jsonData["serviceUUID"],
            deviceUUID = jsonData["deviceUUID"],
            isNotifying = jsonData["isNotifying"],
            value = jsonData["value"],
            properties = BluetoothCharacteristicProperties.fromJson(jsonData["properties"]);

    Future<void> writeValue(Uint8List value) async {
        await _channel.invokeMethod("writeCharacteristic",
            {
                "deviceUUID": deviceUUID,
                "serviceUUID": serviceUUID,
                "characteristicUUID": uuid,
                "value": value
            }
        );
    }

    Future<List> readValue() async {
        return PluginScaffold.createStream(_channel, "readCharacteristic", 
        {
            "deviceUUID": deviceUUID,
            "serviceUUID": serviceUUID,
            "characteristicUUID": uuid,
        }).toList();
    }
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
