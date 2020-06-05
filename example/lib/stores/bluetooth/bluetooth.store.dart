import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mobx/mobx.dart";
import "package:flutter_amazon_freertos_plugin/flutter_amazon_freertos_plugin.dart";
import 'package:permission_handler/permission_handler.dart';

part "bluetooth.store.g.dart";

class BluetoothStore = _BluetoothStore with _$BluetoothStore;

// Bluetooth low energy APIs via Mobx Store
abstract class _BluetoothStore with Store {
    FlutterAmazonFreeRTOSPlugin amazonFreeRTOSPlugin = FlutterAmazonFreeRTOSPlugin.instance;
    StreamSubscription _scanforDevicesSubscription;
    StreamSubscription _deviceStateSubscription;

    @observable
    BluetoothState bluetoothState = BluetoothState.UNKNOWN;

    @observable
    ObservableList<FreeRTOSDevice> devicesNearby = ObservableList.of([]);

    @observable
    FreeRTOSDevice activeDevice;

    @observable
    ObservableList<BluetoothService> services = ObservableList.of([]);

    @observable
    bool isConnecting = false;

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
            devicesNearby = ObservableList.of(await amazonFreeRTOSPlugin.discoveredDevices);
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
            // TODO: Permission validation should be in plugin side?
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
                print("Start scanning for nearby BLE devices");
                devicesNearby.clear();
                // If timeout is not sent, then scanning won't stop until we call amazonFreeRTOSPlugin.stopScanForDevices()
                _scanforDevicesSubscription = amazonFreeRTOSPlugin.startScanForDevices(scanDuration: 3000).listen((scanResult) {                    
                    devicesNearby.add(scanResult);
                }, onDone: () {
                    print("----------- scan done ----------");
                }); 

                // Other way to do it:
                // await for (final scanResult in amazonFreeRTOSPlugin.startScanForDevices()) {}                            
            }
        } catch (e) {
            print("Error: Failed to start scan startScanning()");
            print(e);
        }
    }

    @action
    Future<void> stopScanning() async {
        try {
            _scanforDevicesSubscription.cancel();
            _scanforDevicesSubscription = null;
            amazonFreeRTOSPlugin.stopScanForDevices();
            print("Stop scanning for nearby BLE devices");
        } catch (e) {
            print("Error: Failed to stop scan stopScanning()");
            print(e);
        }
    }

    Future<void> rescan() async {
        try {            
            devicesNearby.clear();
            // If timeout is not sent, then scanning won't stop until we call amazonFreeRTOSPlugin.stopScanForDevices()
            _scanforDevicesSubscription = amazonFreeRTOSPlugin.rescanForDevices(scanDuration: 3000).listen((scanResult) {                    
                devicesNearby.add(scanResult);
            }, onDone: () {
                print("----------- rescan done ----------");
            });
        } catch (e) {
            print("Error: Failed to rescan rescanForDevices()");
            print(e);
        }
    }

    // TODO: Services is empty [] sometimes
    Future<void> _discoverServices() async {        
        services = ObservableList.of(await activeDevice.discoverServices());
        print("services - - - - - - - - - - - - - - - - - - $services");
        // checking each services provided by device
        services.forEach((service) {    
            print("service $service");
        });
    }

    Future<void> connectDevice(FreeRTOSDevice device, BuildContext context) async {
        try {
            if(device != null) {
                activeDevice = device;
                await activeDevice.connect();
                isConnecting = true;
                _deviceStateSubscription = activeDevice.observeState().listen((value) async {                    
                    if (value == FreeRTOSDeviceState.CONNECTED) {
                        // TODO: check if this tiemout is still necessary?
                        // Need to wait for 3 seconds due to Amazon GATT server
                        // demo requiring extra steps to get fully connected
                        // as it required a user verification
                        // Timer(Duration(seconds: 3), () async => await _discoverServices());
                        
                        // TODO: discoverServices is pending
                        // await _discoverServices();
                        Navigator.pushNamed(context, "/bluetoothDevice");
                    }
                    if(value != FreeRTOSDeviceState.CONNECTING) {
                        isConnecting = false;
                    }
                });                  
            }            
        } catch (e) {
            isConnecting = false;
            print("Unable to connect to device: $e");
        }
    }

    @action
    disconnect() {
        devicesNearby.clear();
        services.clear();
        activeDevice.disconnect();
        activeDevice = null;
        _scanforDevicesSubscription.cancel();
        _scanforDevicesSubscription = null;    
        _deviceStateSubscription.cancel();
        _deviceStateSubscription = null;    
        
    }

    // AmazonFreeRTOS GATT Server Demo
    // https://docs.aws.amazon.com/freertos/latest/userguide/ble-demo.html#ble-demo-server
    String get demoService => "c6f2d9e3-49e7-4125-9014-bfc6d669ff00";
    String get demoRead => "c6f2d9e3-49e7-4125-9014-bfc6d669ff01";
    String get demoWrite => "c6f2d9e3-49e7-4125-9014-bfc6d669ff02";

    @computed
    bool get isBluetoothSupportedAndOn => bluetoothState == BluetoothState.POWERED_ON;
}
