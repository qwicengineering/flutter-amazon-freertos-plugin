import "package:flutter/material.dart";
import "package:flutter_amazon_freertos_plugin_example/bluetooth_devices.screen.dart";
import "package:flutter_amazon_freertos_plugin_example/login.screen.dart";
import "package:flutter_amazon_freertos_plugin_example/stores/cognito/cognito.store.dart";
import "package:provider/provider.dart";

class StartWidget extends StatelessWidget {
    
    @override
    Widget build(BuildContext context) {
        final cognitoStore = Provider.of<CognitoStore>(context);

        return FutureBuilder(
            future: () async {
                await cognitoStore.initialize();
            }(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!cognitoStore.isUserSignIn) return LoginScreen();
                return BluetoothDevicesScreen();
            },
        );
    }
}
