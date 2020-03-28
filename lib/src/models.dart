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
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    DISCONNECTING
}

class FreeRTOSDevice {
    final String id;
    final String name;
    final DeviceState state;
    final bool reconnect;
    final String rssi;
    final String certificateId;
    final String brokerEndpoint;
    final int mtu;

    FreeRTOSDevice.fromMsg(List msg) 
        : id = msg[0],
          name = msg[1],
          state = DeviceState.values[msg[2]],
          reconnect = msg[3] == true,
          rssi = msg[4],
          certificateId = msg[5],
          brokerEndpoint = msg[6],
          mtu = msg[7];

    Future<void> connect() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeMethod("connectToDeviceId", {"id": id});
    }

    Future<void> disconnect() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeListMethod("disconnectToDeviceId", {"id": id});
    }

    Future<void> discoverServices() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeMethod("discoverServices");
    }

    Future<void> discoverCharacteristics() async {
        await FlutterAmazonFreeRTOSPlugin.instance.channel.invokeListMethod("discoverCharactersitics");
    }
}