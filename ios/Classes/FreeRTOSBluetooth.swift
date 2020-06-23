import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import CoreBluetooth

class FreeRTOSBluetooth: NSObject {
    let amazonFreeRTOSManager: AmazonFreeRTOSManager
    var notificationObservers = [Int: [NSObjectProtocol]]()
    
    init(_ amazonFreeRTOSManager: AmazonFreeRTOSManager) {
        self.amazonFreeRTOSManager = amazonFreeRTOSManager
        super.init()
    }

    func bluetoothState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = dumpBluetoothState(amazonFreeRTOSManager.central?.state ?? CBManagerState.unknown)
        result(state)
    }

    func readDescriptor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    func writeDescriptor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    func writeCharacteristic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any?] else { return }
        let value = args["value"] as! FlutterStandardTypedData

        let deviceUUIDString = args["deviceUUID"] as! String
        guard let device = getDevice(uuidString: deviceUUIDString) else { return }

        let serviceUUIDString = args["serviceUUID"] as! String
        let serviceUUID = CBUUID(string: serviceUUIDString)
        guard let service = device.peripheral.serviceOf(uuid: serviceUUID) else { return }

        let characteristicUUIDString = args["characteristicUUID"] as! String
        let characteristicUUID = CBUUID(string: characteristicUUIDString)
        guard let characteristic = service.characteristicOf(uuid: characteristicUUID) else { return }

        // Harcoding .withResponse for now.
        // TODO: Retreive .withResponse as from call.arguments
        device.peripheral.writeValue(value.data, for: characteristic, type: .withResponse)
        result(nil)
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

    // Helper functions

    func getDevice(uuidString: String) -> AmazonFreeRTOSDevice? {
        guard let deviceUUID = UUID(uuidString: uuidString),
            let device = amazonFreeRTOSManager.devices[deviceUUID]
            else { return nil }

        return device
    }

}
