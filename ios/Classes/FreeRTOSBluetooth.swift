import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import CoreBluetooth

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared
    var discoveredDevicesTimer = [Int: Timer]();
    
    func bluetoothState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = dumpBluetoothState(awsFreeRTOSManager.central?.state ?? CBManagerState.unknown)
        result(state)
    }
    
    // TODO: Do we need to look for exceptions?
    func startScanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        awsFreeRTOSManager.startScanForDevices()
        result(nil)
    }
    
    // TODO: Do we need to look for exceptions?
    func stopScanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        awsFreeRTOSManager.stopScanForDevices()
        result(nil)
    }
    
    // TODO: Do we need to look for exceptions?
    func rescanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        awsFreeRTOSManager.rescanForDevices()
        result(nil)
    }

    // Discovered devices are usually cached. If there is a new device,
    // it is added to the awsFreeRTOSManager.devices list. 
    // However, a device is not removed automatically.
    // Use rescanForDevices() to reset the awsFreeRTOSManager.devices list
    func listDiscoveredDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var devices: [Any] = []
        for (_, value) in awsFreeRTOSManager.devices {
            devices.append(dumpFreeRTOSDeviceInfo(value))
        }
        result(devices)
    }
    
    func discoverDevicesOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        discoveredDevicesTimer[0] = Timer.scheduledTimer(withTimeInterval: args as! Double / 1000, repeats: true ) {_ in
            for (_, value) in self.awsFreeRTOSManager.devices {
                sink(dumpFreeRTOSDeviceInfo(value))
            }
        }
    }

    func discoverDevicesOnCancel(id: Int, args: Any?) {
        discoveredDevicesTimer[id]?.invalidate()
        discoveredDevicesTimer.removeValue(forKey: id)
    }
    
    func connectToDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func disconnectFromDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func discoverServices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    func listServices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func readCharacteristic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func readDescriptor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func writeDescriptor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result (FlutterMethodNotImplemented)
    }
    
    func writeCharacteristic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result (FlutterMethodNotImplemented)
    }
    
    func setNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func getMtu(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func setMtu(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
}
