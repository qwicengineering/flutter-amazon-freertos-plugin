import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import CoreBluetooth

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared
    var notificationObservers = [Int: [NSObjectProtocol]]()

    func bluetoothState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = dumpBluetoothState(awsFreeRTOSManager.central?.state ?? CBManagerState.unknown)
        result(state)
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

    func listServicesForDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any?] else { return }

        let deviceUUIDString = args["deviceUUID"] as! String
        guard let device = getDevice(uuidString: deviceUUIDString) else { return }

        var services: [Any] = []
        for service in device.peripheral.services ?? [] {
            services.append(dumpFreeRTOSDeviceServiceInfo(service))
        }
        debugPrint("[FreeRTOSBlueTooth] listServicesForDevice deviceUUID: \(device.peripheral.identifier.uuidString)")
        result(services)
    }

    func discoverServices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
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
            let device = awsFreeRTOSManager.devices[deviceUUID]
            else { return nil }

        return device
    }

}
