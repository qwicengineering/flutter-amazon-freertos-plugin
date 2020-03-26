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
                "connectToDevice": plugin.connectToDevice,
                "disconnectFromDevice": plugin.disconnectFromDevice,
                "discoverServices": plugin.discoverServices,
                "listServices": plugin.listServices,
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
        
        // TODO: Convert to stream
        // Only notifies if it identifies a new device is discovered
        // And is not already in the CentralManager.devices list
        NotificationCenter.default.addObserver(forName: .afrCentralManagerDidDiscoverDevice, object: nil, queue: nil) { notification in
            if let data = notification.userInfo as? [String: Any] {
                let deviceId = data.first?.value as! String
                channel.invokeMethod("didDiscoverNewDeviceCallback", arguments: deviceId)
            }
        }
    }
}
