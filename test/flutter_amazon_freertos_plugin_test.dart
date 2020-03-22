import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

void main() {
  const MethodChannel channel = MethodChannel("nl.qwic.plugins.flutter_amazon_freertos_plugin");
  FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return "42";
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test("getBluetoothState", () async {
    expect(await amazonFreeRTOSPlugin.bluetoothState, "42");
  });
}
