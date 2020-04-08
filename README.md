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

### Get discovered devices
```dart
// Use Dart.Timer class to call this peridiocally to refresh the list
List<FreeRTOSDevice> devices = await amazonFreeRTOSPlugin.discoveredDevices;
```

### Example app
Duplicate `example/android/app/src/main/res/raw/awscredentials_template.json` file, rename it into `example/android/app/src/main/res/raw/awscredentials.json` and fill in proper Cognito credentials:
```json
{
	"UserAgent": "MobileHub/1.0",
	"Version": "1.0",
	"CredentialsProvider": {
		"CognitoIdentity": {
			"Default": {
				"PoolId": "Federated Identities -> Edit identity pool -> Identity pool ID. (eg. us-west-2:fc4d19b1-873f-44d8-bdcf-3a8e7aabf3ea)",
				"Region": "Your Region. (eg. us-east-1)"
			}
		}
	},
	"IdentityManager": {
		"Default": {}
	},
	"CognitoUserPool": {
		"Default": {
			"PoolId": "UserPool -> General settings -> Pool Id. (eg. us-east-1_example)",
			"AppClientId": "UserPool -> General settings -> App clients -> Show Details. (eg. 3tcegaot7efa8abgn1fxnebq5)",
			"AppClientSecret": "UserPool -> General settings -> App clients -> Show Details. (eg. dse11rx91vs1t9600uacc0ssw1byju8em3k60271n748s26ts9l)",
			"Region": "Your Region. (eg. us-east-1)"
		}
	}
}
```

### Cognito
Cognito initialization code is in `cognito.store.dart`

## Credits
Heavily influenced by the following plugins.
- [Flutter_blue](https://pub.dartlang.org/packages/flutter_blue)
- [Flutter_cognito_plugin](https://pub.dev/packages/flutter_cognito_plugin)
- [Plugin_scaffold](https://pub.dev/packages/plugin_scaffold)