part of flutter_amazon_freertos_plugin;

typedef OnBluetoothStateChange(BluetoothState bluetoothState);
class FlutterAmazonFreeRTOSPlugin {
static final logger = Logger("FlutterAmazonFreeRTOSPlugin");
static const pkgName = "nl.qwic.plugins.flutter_amazon_freertos_plugin";
final MethodChannel channel = const MethodChannel(pkgName);
static FlutterAmazonFreeRTOSPlugin _instance = new FlutterAmazonFreeRTOSPlugin();
static FlutterAmazonFreeRTOSPlugin get instance => _instance;

Future<BluetoothState> get bluetoothState async {
    final int bluetoothState = await channel.invokeMethod("bluetoothState");
    return BluetoothState.values[bluetoothState];
}

void registerBluetoothStateChangeCallback(OnBluetoothStateChange onBluetoothStateChange) {
    const _method = "bluetoothStateChangeCallback";

    if (onBluetoothStateChange == null) {
        PluginScaffold.removeCallHandlersWithName(channel, _method);
        return;
    }

    PluginScaffold.setCallHandler(channel, _method, (bluetoothState) {
        onBluetoothStateChange(BluetoothState.values[bluetoothState]);
    });
}

Stream<FreeRTOSDevice> startScanForDevices({ List<String> serviceUUIDS: const [], int scanDuration = 0}) {
    return PluginScaffold.createStream(channel, "startScanForDevices", {
        "serviceUUIDS": serviceUUIDS,
        "scanDuration": scanDuration,
    }).map((value) {
        return FreeRTOSDevice.fromJson(value);
    }).handleError((e) {
        Exception(e);
    });
}

Future<void> stopScanForDevices() async {
    await channel.invokeMethod("stopScanForDevices");
}

Stream<FreeRTOSDevice> rescanForDevices({List<String> serviceUUIDS = const [], int scanDuration = 0}) {
    return PluginScaffold.createStream(channel, "rescanForDevices", {
        "servieUUIDS": serviceUUIDS,
        "scanDuration": scanDuration,
    }).map((value) {
        return FreeRTOSDevice.fromJson(value);
    }).handleError((e) {
        Exception(e);
    });
}

Future<List<FreeRTOSDevice>> get discoveredDevices async {
    final List devices = await channel.invokeListMethod("listDiscoveredDevices");
    return List<FreeRTOSDevice>.from(devices.map((device) {
        return FreeRTOSDevice.fromJson(device);
    }));
}

//String get pkgName => pkgName;
}
