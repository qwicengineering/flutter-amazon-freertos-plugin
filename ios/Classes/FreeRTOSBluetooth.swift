import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import CoreBluetooth

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared
    
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
