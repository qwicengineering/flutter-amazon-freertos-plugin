# flutter_amazon_freertos_plugin

Flutter plugin wrapper for amazon freertos ios and android sdk

## Development

This library is being actively developed by the QWIC team. It is meant for internal experimentation with amazon freertos devices

## Usuage
### Obtain an instance
```dart
FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;
```

### Check for bluetooth state
```dart
BluetoothState bluetoothState = await amazonFreeRTOSPlugin.bluetoothState;

// Listen to bluetooth state changes
amazonFreeRTOSPlugin.registerBluetoothStateChangeCallback((bluetoothState) {
    if(!mounted) return;

    setState(() {
        _bluetoothState = bluetoothState;
    });
});
```

## Credits
Heavily influenced by the following plugins.
- [Flutter_blue](https://pub.dartlang.org/packages/flutter_blue)
- [Flutter_cognito_plugin](https://pub.dev/packages/flutter_cognito_plugin)
- [Plugin_scaffold](https://pub.dev/packages/plugin_scaffold)