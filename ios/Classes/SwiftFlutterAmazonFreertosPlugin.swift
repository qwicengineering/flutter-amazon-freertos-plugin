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
                "startScanForDevicesOnListen": plugin.startScanForDevicesOnListen,
                "startScanForDevicesOnCancel": plugin.startScanForDevicesOnCancel,
                "rescanForDevices": plugin.rescanForDevices,
                "connectToDeviceId": plugin.connectToDeviceId,
                "disconnectFromDeviceId": plugin.disconnectFromDeviceId,
                "deviceState": plugin.deviceState,
                "deviceStateOnListen": plugin.deviceStateOnListen,
                "deviceStateOnCancel": plugin.deviceStateOnCancel,
                "listDiscoveredDevices": plugin.listDiscoveredDevices,
                "listServicesForDeviceId": plugin.listServicesForDevice,
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
        
        // FreeRTOS BLE Central Manager didConnectDevice
        // Discover all custom services
        NotificationCenter.default.addObserver(forName: .afrCentralManagerDidConnectDevice, object: nil, queue: nil) { notification in
            let deviceUUID = notification.userInfo?["identifier"] as! UUID
            guard let device = plugin.awsFreeRTOSManager.devices[deviceUUID] else { return }
            device.peripheral.discoverServices([])
        }
    }
}
