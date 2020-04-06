import "package:flutter/material.dart";
import 'package:flutter_amazon_freertos_plugin_example/stores/bluetooth/bluetooth.store.dart';
import "package:flutter_amazon_freertos_plugin_example/verify_user.screen.dart";
import "package:flutter_amazon_freertos_plugin_example/widgets/start.widget.dart";
import "package:provider/provider.dart";

import "bluetooth_devices.screen.dart";
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
        Provider<BluetoothStore>(create: (_) => BluetoothStore()),
        Provider<CognitoStore>(create: (_) => CognitoStore()),
      ],
      child: MaterialApp(
        title: "Amazon FreeRTOS BLE Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StartWidget(),
        initialRoute: "/",
        routes: {
          "/login": (context) => LoginScreen(),
          "/verifyUser": (context) => VerifyUserScreen(),
          "/bluetoothDevices": (context) => BluetoothDevicesScreen()
        },
      ),
    );
  }
}
