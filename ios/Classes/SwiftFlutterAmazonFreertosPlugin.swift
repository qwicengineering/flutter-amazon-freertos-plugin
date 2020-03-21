import Flutter
import UIKit
import plugin_scaffold
import CoreBluetooth

let pkgName = "nl.qwic.plugins.flutter_amazon_freertos_plugin"

public class SwiftFlutterAmazonFreeRTOSPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = FreeRTOSBluetooth()
        _ = createPluginScaffold(
            messenger: registrar.messenger(),
            channelName: pkgName,
            methodMap: [
                "isAvailable": plugin.isAvailable,
                "isOn": plugin.isOn,
                "startScanning": plugin.startScanning,
                "stopScanning": plugin.stopScanning,
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
        ])
    }

}
