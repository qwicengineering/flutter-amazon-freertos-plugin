import Flutter
import UIKit
import plugin_scaffold
import CoreBluetooth


let pkgName = "nl.qwic.plugins.flutter_amazon_freertos_plugin"

public class SwiftFlutterAmazonFreeRTOSPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = FreeRTOSBluetooth()
        let channel = createPluginScaffold(
            messenger: registrar.messenger(),
            channelName: pkgName,
            methodMap: [
                "bluetoothState": plugin.bluetoothState,
                "startScanForDevices": plugin.startScanForDevices,
                "stopScanForDevices": plugin.stopScanForDevices,
                "rescanForDevices": plugin.rescanForDevices,
                "connectToDeviceId": plugin.connectToDeviceId,
                "disconnectFromDeviceId": plugin.disconnectFromDeviceId,
                "listServicesForDeviceId": plugin.listServicesForDeviceId,
                "listDiscoveredDevices": plugin.listDiscoveredDevices,
                "readCharacteristic": plugin.readCharacteristic,
                "readDescriptor": plugin.readDescriptor,
                "writeDescriptor": plugin.writeDescriptor,
                "writeCharacteristic": plugin.writeCharacteristic,
                "setNotification": plugin.setNotification,
                "getMtu": plugin.getMtu,
                "setMtu": plugin.setMtu
            ]
        )
        
        // FreeRTOS BLE Central Manager didUpdateState
        NotificationCenter.default.addObserver(forName: .afrCentralManagerDidUpdateState, object: nil, queue: nil) { notification in
            let state = dumpBluetoothState(plugin.awsFreeRTOSManager.central?.state ?? CBManagerState.unknown)
            channel.invokeMethod("bluetoothStateChangeCallback", arguments: state)
        }
        
    }
}
