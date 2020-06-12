import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import CoreBluetooth

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared
    var notificationObservers = [Int: [NSObjectProtocol]]()

    func bluetoothState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = dumpBluetoothState(awsFreeRTOSManager.central?.state ?? CBManagerState.unknown)
        result(state)
    }

    // TODO: Do we need to look for exceptions?
    func startScanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var advertisingServiceUUIDs: [CBUUID] = awsFreeRTOSManager.advertisingServiceUUIDs

        if let central = awsFreeRTOSManager.central {
            if let args = call.arguments as? [String: Any?], let customServiceUUIDs = args["serviceUUIDS"] as? [CBUUID] {
               advertisingServiceUUIDs += customServiceUUIDs
            }
            central.scanForPeripherals(withServices: advertisingServiceUUIDs, options: nil)
            debugPrint("[FreeRTOSBluetooth] startScanForDevices")
        }
    }

    // TODO: Do we need to look for exceptions?
    func stopScanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        awsFreeRTOSManager.stopScanForDevices()
        debugPrint("[FreeRTOSBluetooth] stopScanForDevices")
    }

    func startScanForDevicesOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        var advertisingServiceUUIDs: [CBUUID] = awsFreeRTOSManager.advertisingServiceUUIDs

        if let central = awsFreeRTOSManager.central {
            let args = args as! [String: Any?]
            let scanDuration = args["scanDuration"] as? Int ?? 1000

            if let customServiceUUIDs = args["serviceUUIDS"] as? [CBUUID] {
               advertisingServiceUUIDs += customServiceUUIDs
            }
            debugPrint("[FreeRTOSBluetooth] startScanForDevicesOnListen id: \(id), advertisingUUIDs: \(advertisingServiceUUIDs) scanDuration:\(scanDuration)")
            central.scanForPeripherals(withServices: advertisingServiceUUIDs, options: nil)
            sendDiscoveredDeviceInfo(id: id, scanDuration: scanDuration, sink: sink)
        }
    }

    func startScanForDevicesOnCancel(id: Int, args: Any?) {
        guard let observers = notificationObservers[id] else { return }
        for obeserver in observers {
            NotificationCenter.default.removeObserver(obeserver)
        }
        debugPrint("[FreeRTOSBluetooth] startScanForDevicesOnCancel id: \(id)")
    }

    func sendDiscoveredDeviceInfo(id: Int, scanDuration: Int, sink: @escaping FlutterEventSink) {
        let scanForDevicesObserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidDiscoverDevice, object: nil, queue: nil)
        { notification in
                let notificationDeviceUUID = notification.userInfo?["identifier"] as! UUID
                guard let device = self.awsFreeRTOSManager.devices[notificationDeviceUUID] else { return }
                debugPrint("[FreeRTOSBluetooth] sendDiscoveredDeviceInfo deviceUUID: \(notificationDeviceUUID)")
                sink(dumpFreeRTOSDeviceInfo(device))
        }
        notificationObservers[id] = [scanForDevicesObserver]

        // Do not end stream if scanDuration is 0
        guard scanDuration > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(scanDuration)) {
                sink(FlutterEndOfEventStream)
            }
            return
        }
    }

    // TODO: Do we need to look for exceptions?
    func rescanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        awsFreeRTOSManager.stopScanForDevices()

        for device in awsFreeRTOSManager.devices.values {
            device.disconnect()
        }
        awsFreeRTOSManager.devices.removeAll()

        var advertisingServiceUUIDs: [CBUUID] = awsFreeRTOSManager.advertisingServiceUUIDs

        if let central = awsFreeRTOSManager.central, !central.isScanning {
            if let args = call.arguments as? [String: Any?], let customServiceUUIDs = args["serviceUUIDS"] as? [CBUUID] {
               advertisingServiceUUIDs += customServiceUUIDs
            }
            central.scanForPeripherals(withServices: advertisingServiceUUIDs, options: nil)
        }
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

    func connectToDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["deviceUUID"] as! String
        let reconnect = args["reconnect"] as? Bool ?? true

        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device = awsFreeRTOSManager.devices[deviceUUID] {
            debugPrint("[FreeRTOSBluetooth] connectToDeviceId deviceUUID: \(deviceUUID)")
            device.connect(reconnect: reconnect, credentialsProvider: AWSMobileClient.default())
        }
    }

    func disconnectFromDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["deviceUUID"] as! String

        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device = awsFreeRTOSManager.devices[deviceUUID] {
            debugPrint("[FreeRTOSBluetooth] disconnectFromDeviceId deviceUUID: \(deviceUUID)")
            device.disconnect()
        }
    }

    func deviceState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceUUIDString = args["deviceUUID"] as! String

        guard let device = getDevice(uuidString: deviceUUIDString) else { return }
        result(dumpDeviceState(device.peripheral.state))
    }

    func deviceStateOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        let deviceUUIDString = args as? String ?? ""
        let deviceUUID = UUID(uuidString: deviceUUIDString)

        debugPrint("[FreeRTOSBlueTooth] deviceStateOnListen id: \(id)")
        // FreeRTOS BLE Central Manager didUpdateState
        let connectObeserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidConnectDevice, object: nil, queue: nil) { notification in
            let notificationDeviceUUID = notification.userInfo?["identifier"] as! UUID
            guard deviceUUID == notificationDeviceUUID, let device = self.awsFreeRTOSManager.devices[notificationDeviceUUID] else { return }
                let deviceState = dumpDeviceState(device.peripheral.state)
                debugPrint("[FreeRTOSBlueTooth] deviceStateOnListen deviceUUID: \(notificationDeviceUUID), state: \(deviceState)")
                sink(deviceState)
        }

        // FreeRTOS BLE Central Manager didUpdateState
        let disconnectObserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidDisconnectDevice, object: nil, queue: nil) { notification in
            let notificationDeviceUUID = notification.userInfo?["identifier"] as! UUID
            guard deviceUUID == notificationDeviceUUID, let device = self.awsFreeRTOSManager.devices[notificationDeviceUUID] else { return }
            let deviceState = dumpDeviceState(device.peripheral.state)
            debugPrint("[FreeRTOSBlueTooth] deviceStateOnListen deviceUUID: \(notificationDeviceUUID), state: \(deviceState)")
            sink(deviceState)
        }

        notificationObservers[id] = [connectObeserver, disconnectObserver]
    }

    func deviceStateOnCancel(id: Int, args: Any?) {
        guard let observers = notificationObservers[id] else { return }
        for obeserver in observers {
            NotificationCenter.default.removeObserver(obeserver)
        }
        debugPrint("[FreeRTOSBlueTooth] deviceStateOnCancel id: \(id)")
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

    // Attaches proper policy to the Cognito on sign-in
    // This allows user to subscribe and publish messages to IoT Core
    // via MQTT protocol
    // See https://github.com/aws-samples/aws-iot-chat-example/blob/master/docs/authentication.md
    // This is used strictly for example code
    // TODO: Create a serverless example
    func attachPrincipalPolicy() {

        AWSMobileClient.default().getIdentityId().continueWith { task -> Any? in

            if let error = task.error {
                print(error)
                return task
            }

            guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest(), let principal = task.result else {
                return task
            }

            attachPrincipalPolicyRequest.policyName = ""
            attachPrincipalPolicyRequest.principal = String(principal)

            let configuration = AWSServiceConfiguration(
                region: .Unknown, credentialsProvider: AWSMobileClient.default()
            )

            AWSServiceManager.default()?.defaultServiceConfiguration = configuration

            AWSIoT.default().attachPrincipalPolicy(attachPrincipalPolicyRequest, completionHandler: { error in
                if let error = error {
                    print(error)
                }
            })

            return task
        }
    }

    // Helper functions

    func getDevice(uuidString: String) -> AmazonFreeRTOSDevice? {
        guard let deviceUUID = UUID(uuidString: uuidString),
            let device = awsFreeRTOSManager.devices[deviceUUID]
            else { return nil }

        return device
    }

}
