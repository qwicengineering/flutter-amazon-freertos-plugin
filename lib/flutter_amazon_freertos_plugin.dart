import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAmazonFreeRTOSPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_amazon_freertos_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
