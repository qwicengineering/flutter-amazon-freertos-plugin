import Flutter
import UIKit
import plugin_scaffold
import CoreBluetooth
import AmazonFreeRTOS


let pkgName = "nl.qwic.plugins.flutter_amazon_freertos_plugin"

public class SwiftFlutterAmazonFreeRTOSPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let amazonFreeRTOSManager = AmazonFreeRTOSManager.shared
        let scanMethods = FreeRTOSBluetoothScan(amazonFreeRTOSManager)
        let connectMethods = FreeRTOSBluetoothConnect(amazonFreeRTOSManager)
        let plugin = FreeRTOSBluetooth(amazonFreeRTOSManager)
        let channel = createPluginScaffold(
            messenger: registrar.messenger(),
            channelName: pkgName,
            methodMap: [
                "bluetoothState": plugin.bluetoothState,
                "stopScanForDevices": scanMethods.stopScanForDevices,
                "startScanForDevicesOnListen": scanMethods.startScanForDevicesOnListen,
                "startScanForDevicesOnCancel": scanMethods.startScanForDevicesOnCancel,
                "rescanForDevices": scanMethods.rescanForDevices,
                "connectToDeviceId": connectMethods.connectToDevice,
                "disconnectFromDeviceId": connectMethods.disconnectFromDevice,
                "deviceStateOnListen": connectMethods.deviceStateOnListen,
                "deviceStateOnCancel": connectMethods.deviceStateOnCancel,
                "deviceState": connectMethods.getDeviceState,
                "discoverServices": connectMethods.discoverServices,
                "discoverServicesOnListen": connectMethods.discoverServicesOnListen,
                "discoverServicesOnCancel": connectMethods.discoverServicesOnCancel,
                "writeDescriptor": plugin.writeDescriptor,
                "writeCharacteristic": plugin.writeCharacteristic,
                "setNotification": plugin.setNotification,
                "getMtu": plugin.getMtu,
                "setMtu": plugin.setMtu
            ]
        )

        // FreeRTOS BLE Central Manager didUpdateState
        NotificationCenter.default.addObserver(forName: .afrCentralManagerDidUpdateState, object: nil, queue: nil) { notification in
            let state = dumpBluetoothState(plugin.amazonFreeRTOSManager.central?.state ?? CBManagerState.unknown)
            channel.invokeMethod("bluetoothStateChangeCallback", arguments: state)
        }
    }
}
