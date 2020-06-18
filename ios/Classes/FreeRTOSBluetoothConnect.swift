import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import CoreBluetooth

class FreeRTOSBluetoothConnect: NSObject {
    let amazonFreeRTOSManager: AmazonFreeRTOSManager
    var notificationObservers = [Int: [NSObjectProtocol]]()

    init(_ amazonFreeRTOSManager: AmazonFreeRTOSManager) {
        self.amazonFreeRTOSManager = amazonFreeRTOSManager
        super.init()
    }

    func _setupStateNotifications(_ id: Int, _ sink: @escaping FlutterEventSink) {
        let connectObeserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidConnectDevice, object: nil, queue: nil) { notification in
            let deviceId = notification.userInfo?["identifier"] as! UUID

            guard let device = self._getDevice(deviceId.uuidString) else { return }

            let deviceState = dumpDeviceState(device.peripheral.state)
            debugPrint("[FreeRTOSBlueTooth] deviceId: \(deviceId), state: \(deviceState)")
            sink(deviceState)
        }

        // FreeRTOS BLE Central Manager didUpdateState
        let disconnectObserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidDisconnectDevice, object: nil, queue: nil) { notification in
            let deviceId = notification.userInfo?["identifier"] as! UUID

            guard let device = self._getDevice(deviceId.uuidString) else { return }

            let deviceState = dumpDeviceState(device.peripheral.state)
            debugPrint("[FreeRTOSBluetoothConnect] deviceId: \(deviceId), state: \(deviceState)")
            sink(deviceState)
        }

        let failedToConnectObserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidFailToConnectDevice, object: nil, queue: nil) { notification in
            let deviceId = notification.userInfo?["identifier"] as! UUID

            guard let device = self._getDevice(deviceId.uuidString) else { return }

            let deviceState = dumpDeviceState(device.peripheral.state)
            debugPrint("[FreeRTOSBluetoothConnect] deviceId: \(deviceId), state: \(deviceState)")
            sink(deviceState)
        }

        notificationObservers[id] = [connectObeserver, disconnectObserver, failedToConnectObserver]
    }

    func deviceStateOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        let deviceId = args as? String ?? ""
        guard let device = _getDevice(deviceId) else {
            debugPrint("[FreeRTOSBluetoothConnect] onListen device not found id:\(deviceId)")
            return
        }

        debugPrint("[FreeRTOSBluetooth] connectToDeviceId deviceUUID: \(device.peripheral.identifier.uuidString)")
        _setupStateNotifications(id, sink)
    }

    func deviceStateOnCancel(id: Int, args: Any?) {

        guard let observers = notificationObservers[id] else { return }

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        debugPrint("[FreeRTOSBlueTooth] deviceStateOnCancel id: \(id)")

    }

    func connectToDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as! [String: Any?]
        let deviceId = map["deviceUUID"] as! String
        let reconnect = map["reconnect"] as? Bool ?? true

        guard let device = _getDevice(deviceId) else {
            debugPrint("[FreeRTOSBluetoothConnect] connectToDeviceId device not found id:\(deviceId)")
            return
        }

        // TODO: Invoke attachPrincipalPolicy using channel method
        // _attachPrincipalPolicy()
        device.connect(reconnect: reconnect, credentialsProvider: AWSMobileClient.default())
        result(nil)
    }


    func disconnectFromDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as! [String: Any?]
        let deviceId = map["deviceUUID"] as! String
        guard let device = _getDevice(deviceId) else {
            debugPrint("[FreeRTOSBluetoothConnect] connectToDeviceId device not found id:\(deviceId)")
            return
        }

        device.disconnect()
        result(nil)
    }

    func getDeviceState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as! [String: Any?]
        let deviceId = map["deviceUUID"] as! String

        guard let device = _getDevice(deviceId) else {
            debugPrint("[FreeRTOSBluetoothConnect] getDeviceState device not found for deviceId: \(deviceId)")
            return
        }

        result(dumpDeviceState(device.peripheral.state))
    }

    func discoverServices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as! [String: Any?]
        let deviceId = map["deviceUUID"] as! String
        let customServiceUUIDs = map["serviceUUIDS"] as? [String] ?? []

        guard let device = _getDevice(deviceId) else {
            debugPrint("[FreeRTOSBluetoothConnect] connectToDeviceId device not found id:\(deviceId)")
            return
        }

        device.peripheral.discoverServices(customServiceUUIDs.map { CBUUID(string: "\($0)") })
        result(nil)
    }

    func discoverServicesOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        debugPrint("[FreeRTOSBluetoothConnect] discoverServicesOnListen id: \(id)")

        let discoverServicesObserver = NotificationCenter.default.addObserver(forName: .afrPeripheralDidDiscoverServices, object: nil, queue: nil) {
            notification in
            let device = notification.userInfo?["peripheral"] as! CBPeripheral

            for service in device.services ?? [] {
                let response = dumpFreeRTOSDeviceServiceInfo(service)
                debugPrint("[FreeRTOSBluetoothConnect] discoveredService deviceUUID: \(device.identifier.uuidString), serviceUUID: \(service.uuid.uuidString)")
                device.discoverCharacteristics(nil, for: service)
                sink(response)
            }

            // End stream asynchrously since not all of the events were being
            // captured on Flutter
            DispatchQueue.main.async {
                sink(FlutterEndOfEventStream)
            }

        }
        notificationObservers[id] = [discoverServicesObserver]
    }

    func discoverServicesOnCancel(id: Int, args: Any?) {
        guard let observers = notificationObservers[id] else { return }

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        debugPrint("[FreeRTOSBluetoothConnect] discoverServicesOnCancel id: \(id)")
    }

    // Attaches proper policy to the Cognito on sign-in
    // This allows user to subscribe and publish messages to IoT Core
    // via MQTT protocol
    // See https://github.com/aws-samples/aws-iot-chat-example/blob/master/docs/authentication.md
    // This is used strictly for example code
    // TODO: Create a serverless example
    func _attachPrincipalPolicy() {

        AWSMobileClient.default().getIdentityId().continueWith { task -> Any? in

            if let error = task.error {
                print(error)
                return task
            }

            guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest(), let principal = task.result else {
                return task
            }

            attachPrincipalPolicyRequest.policyName = "IoT_ESP_AuthPolicy"
            attachPrincipalPolicyRequest.principal = String(principal)

            let configuration = AWSServiceConfiguration(
                region: .EUWest1, credentialsProvider: AWSMobileClient.default()
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

    func _getDevice(_ uuidString: String) -> AmazonFreeRTOSDevice? {
        guard let deviceUUID = UUID(uuidString: uuidString),
            let device = amazonFreeRTOSManager.devices[deviceUUID]
            else { return nil }

        return device
    }
}
