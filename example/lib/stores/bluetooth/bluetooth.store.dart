import 'dart:async';

import "package:mobx/mobx.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";

part "bluetooth.store.g.dart";

class BluetoothStore = _BluetoothStore with _$BluetoothStore;

// Bluetooth low energy APIs via Mobx Store
abstract class _BluetoothStore with Store {
    
    FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;

    @observable
    BluetoothState bluetoothState = BluetoothState.UNKNOWN;

    @observable
    List<FreeRTOSDevice> devicesNearby = [];

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
            devicesNearby =  await amazonFreeRTOSPlugin.discoveredDevices;
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
            await amazonFreeRTOSPlugin.startScanForDevices();
            print("Start scanning for nearby BLE devices");
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
        } catch(e) {
            print("Error: Failed to rescan rescanForDevices()");
            print(e);
        }
    }

    @computed
    bool get isBluetoothSupportedAndOn => bluetoothState == BluetoothState.POWERED_ON;

}