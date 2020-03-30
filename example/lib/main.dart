import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "bluetooth/bluetooth_devices.screen.dart";
import "stores/auth/auth_form.store.dart";
import "stores/cognito/cognito.store.dart";
import "login.screen.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MultiProvider(
            providers: [
                Provider<AuthFormStore>(create: (_) => AuthFormStore()),
                Provider<CognitoStore>(create: (_) => CognitoStore()),
            ],
            child: MaterialApp(
                title: "Amazon FreeRTOS BLE Demo",
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                ),
                home: LoginScreen(),
                routes: {
                    "/login": (context) => LoginScreen(),
                    "/bluetoothDevices": (context) => BluetoothDevicesScreen()
                },
            ),
        );
    }
}
