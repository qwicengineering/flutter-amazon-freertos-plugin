import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import CoreBluetooth

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared
    
    func isAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("is bluetooth available")
    }

    func isOn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("is bluetooth on")
    }
    
    func startScanning(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    func stopScanning(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
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
