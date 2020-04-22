import 'dart:async';
import 'dart:io';

import "package:mobx/mobx.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";
import 'package:permission_handler/permission_handler.dart';

part "bluetooth.store.g.dart";

class BluetoothStore = _BluetoothStore with _$BluetoothStore;

// Bluetooth low energy APIs via Mobx Store
abstract class _BluetoothStore with Store {
    FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;

    @observable
    BluetoothState bluetoothState = BluetoothState.UNKNOWN;

    @observable
    List<FreeRTOSDevice> devicesNearby = [];

    @observable
    FreeRTOSDevice activeDevice;

    @action
    Future<void> initialize() async {
        try {
            bluetoothState = await amazonFreeRTOSPlugin.bluetoothState;
            amazonFreeRTOSPlugin.registerBluetoothStateChangeCallback(setBluetoothState);
        } catch (e) {
            print("Error: initializing bluetooth store");
            print(e);
        }
    }

    /*
        * Stream option to discover nearby devices?
        Future<void> _getDevicesNearby() async {
        amazonFreeRTOSPlugin.discoverDevices.listen((device) {
            print(device);
        });
        }
    */

    @action
    Future<void> getDevicesNearby() async {
        // Nearby devices list are usually cached.
        // If there is a new device discovered nearby, it is added to the list
        // automatically. This is not the the case if the device that was previously
        // discovered and in list turned off (for any reason). It does not get removed
        // from list automatically.
        // rescanForDevices() freshes the device list from the platform side.
        try {
            devicesNearby = await amazonFreeRTOSPlugin.discoveredDevices;
            print("devicesNearby");
            print(devicesNearby);
        } catch (e) {
            print("Error: Failed to retreive nearby devices");
            print(e);
        }
    }

    @action
    void setBluetoothState(BluetoothState value) {
        bluetoothState = value;
    }

    Future<void> startScanning() async {
        try {
            // Location permission needed on Android to scan devices
            // (Requesting Runtime Permissions needed for Android SDK 23 and higher)
            // AWSfreeRTOS is using Android SDK 23
            // https://developer.android.com/distribute/best-practices/develop/runtime-permissions
            // https://developer.radiusnetworks.com/2015/09/29/is-your-beacon-app-ready-for-android-6.html
            // Using this Flutter plugin: https://pub.dev/packages/permission_handler#-example-tab-
            var status = PermissionStatus.undetermined;

            if(Platform.isAndroid){
                status = await Permission.location.status;
                if(status == PermissionStatus.permanentlyDenied) {
                    // The user opted to never again see the permission request dialog for this
                    // app. The only way to change the permission's status now is to let the
                    // user manually enable it in the system settings.
                    openAppSettings(); 
                    return;
                }
                if(status != PermissionStatus.granted) {
                    // Request the permission if not granted
                    status = await Permission.location.request();
                }
            }
            if(
                Platform.isIOS || 
                (Platform.isAndroid && status == PermissionStatus.granted)
            ) {
                await amazonFreeRTOSPlugin.startScanForDevices();
                print("Start scanning for nearby BLE devices");
            }
        } catch (e) {
            print("Error: Failed to start scan startScanning()");
            print(e);
        }
    }

    @action
    Future<void> stopScanning() async {
        try {
            amazonFreeRTOSPlugin.stopScanForDevices();
            print("Stop scanning for nearby BLE devices");
        } catch (e) {
            print("Error: Failed to stop scan stopScanning()");
            print(e);
        }
    }

    Future<void> rescan() async {
        try {
            amazonFreeRTOSPlugin.rescanForDevices();
        } catch (e) {
            print("Error: Failed to rescan rescanForDevices()");
            print(e);
        }
    }

    Future<void> connectDevice(FreeRTOSDevice device) async {
        try {
            device.connect();
            activeDevice = device;
        } catch (e) {
            print("Unable to connect to device");
        }
    }

    // AmazonFreeRTOS GATT Server Demo
    // https://docs.aws.amazon.com/freertos/latest/userguide/ble-demo.html#ble-demo-server
    String get demoService => "c6f2d9e3-49e7-4125-9014-bfc6d669ff00";
    String get demoRead => "c6f2d9e3-49e7-4125-9014-bfc6d669ff01";
    String get demoWrite => "c6f2d9e3-49e7-4125-9014-bfc6d669ff02";

    @computed
    bool get isBluetoothSupportedAndOn => bluetoothState == BluetoothState.POWERED_ON;
}