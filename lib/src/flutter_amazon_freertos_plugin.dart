part of flutter_amazon_freertos_plugin;

class FlutterAmazonFreeRTOSPlugin {
    static final logger = Logger("FlutterAmazonFreeRTOSPlugin");

    static const pkgName = "nl.qwic.plugins.flutter_amazon_freertos_plugin";
    final MethodChannel _channel = const MethodChannel(pkgName);

    static FlutterAmazonFreeRTOSPlugin _instance = new FlutterAmazonFreeRTOSPlugin();
    static FlutterAmazonFreeRTOSPlugin get instance => _instance;

    Future<bool> get isAvailable async {
        final bool bluetoothIsAvailable = await _channel.invokeMethod("isAvailable");
        return bluetoothIsAvailable;
    }

    Future<bool> get isOn async {
        final bool bluetoothIsOn = await _channel.invokeMethod("isOn");
        return bluetoothIsOn;
    }
}
