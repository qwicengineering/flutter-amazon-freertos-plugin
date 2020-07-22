import UIKit
import AmazonFreeRTOS
import AWSIoT
import AWSMobileClient
import CoreBluetooth

enum FreeRTOSBluetoothError: Error {
    case failedToConnectToDevice
    case disconnectFromDevice
    case deviceNotFound
    case deviceNotConnected
    case emptyCustomServiceArguments
}
/**
 FreeRTOSBluetooth: Main class to manage device connections
 device = AmazonFreeRTOSDevice
 peripheral = CBPeripheral
 */
class FreeRTOSBluetooth: NSObject {
    let amazonFreeRTOSManager: AmazonFreeRTOSManager = AmazonFreeRTOSManager.shared
    var notificationObservers = [Int: [NSObjectProtocol]]()
    var connectedPeripherals: [UUID: CBPeripheral] = [:]
    var central: CBCentralManager?
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
        // Use sdk notification characteristic success to check for bonding
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedObserver), name: .afrCentralManagerDidConnectDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPeripheral), name: .afrCentralManagerDidFailToConnectDevice, object: nil)
    }

    func bluetoothState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let state = dumpBluetoothState(self.central?.state ?? CBManagerState.unknown)
        result(state)
    }
    
    func connectToDevice(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let map = call.arguments as! [String: Any?]
        let uuidString = map["deviceUUID"] as! String
        let reconnect = map["reconnect"] as? Bool ?? true
        
        guard let device = getAmazonFreeRTOSDevice(uuidString: uuidString) else {
            debugPrint("[FreeRTOSBluetooth] connectToDevice cannot find device uuid: \(uuidString)")
            throw FreeRTOSBluetoothError.deviceNotFound
        }
        
        device.connect(reconnect: reconnect, credentialsProvider: AWSMobileClient.default())
        result(nil)
    }
    
    func disconnectFromDevice(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let map = call.arguments as! [String: Any?]
        let uuidString = map["deviceUUID"] as! String
        
        guard let device = getAmazonFreeRTOSDevice(uuidString: uuidString) else {
            debugPrint("[FreeRTOSBluetooth] disconnectFromDevice cannot find device uuid: \(uuidString)")
            throw FreeRTOSBluetoothError.deviceNotFound
        }
        
        device.disconnect()
        
        // Clean up local peripheral connection
        if let peripheral = connectedPeripherals[device.peripheral.identifier], peripheral.state == .connected {
            central?.cancelPeripheralConnection(peripheral)
        }
        result(nil)
    }
    
    func discoverServices(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let map = call.arguments as! [String: Any?]
        let deviceUUIDString = map["deviceUUID"] as! String
        let serviceUUIDStrings = map["serviceUUIDS"] as? [String] ?? []
        
        guard let device = getAmazonFreeRTOSDevice(uuidString: deviceUUIDString) else {
            debugPrint("[FreeRTOSBluetooth] disconnectFromDevice cannot find device uuid: \(deviceUUIDString)")
            throw FreeRTOSBluetoothError.deviceNotFound
        }
        
        let customServiceUUIDS: [CBUUID] = serviceUUIDStrings.map { CBUUID(string: "\($0)") }
        guard let peripheral = connectedPeripherals[device.peripheral.identifier], peripheral.state == .connected else {
            debugPrint("[FreeRTOSBluetooth] cannot find local peripheral reference")
            throw FreeRTOSBluetoothError.deviceNotFound
        }
        
        peripheral.discoverServices(customServiceUUIDS)
        result(nil)
    }
    
    func discoverServicesOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        let map = args as! [String: Any?]
        let deviceUUIDString = map["deviceUUID"] as! String
        
        let discoverServicesObserver = NotificationCenter.default.addObserver(forName: .flutterFreeRTOSPeripheralDidDiscoverCharacteristics, object: nil, queue: nil) {
            notification in
            
            guard let peripheral = notification.userInfo?["peripheral"] as? CBPeripheral, peripheral.identifier.uuidString == deviceUUIDString else {
                DispatchQueue.main.async {
                    sink(FlutterEndOfEventStream)
                }
                return
            }
            
            for service in peripheral.services ?? [] {
                let response = dumpFreeRTOSDeviceServiceInfo(service)
                sink(response)
            }
            
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
        guard let device = getAmazonFreeRTOSDevice(uuidString: deviceUUIDString) else { return }

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
    
    func setNotify(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
    // Attaches proper policy to the Cognito on sign-in
    // This allows user to subscribe and publish messages to IoT Core
    // via MQTT protocol
    // See https://github.com/aws-samples/aws-iot-chat-example/blob/master/docs/authentication.md
    // This is used strictly for example code
    // TODO: Create a serverless example
    func attachPrincipalPolicy(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let map = call.arguments as! [String: Any?]
        let policyName = map["policyName"] as! String
        let region = map["awsRegion"] as! Int
        
        AWSMobileClient.default().getIdentityId().continueWith { task -> Any? in
            
            if let error = task.error {
                print(error)
                return task
            }
            
            guard let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest(), let principal = task.result else {
                return task
            }
            
            attachPrincipalPolicyRequest.policyName = policyName
            attachPrincipalPolicyRequest.principal = String(principal)
            
            let awsRegion = AWSRegionType(rawValue: region) ?? AWSRegionType.EUWest1
            
            let configuration = AWSServiceConfiguration(
                region: awsRegion, credentialsProvider: AWSMobileClient.default()
            )
            
            AWSServiceManager.default()?.defaultServiceConfiguration = configuration
            
            AWSIoT.default().attachPrincipalPolicy(attachPrincipalPolicyRequest, completionHandler: { error in
                if let error = error {
                    print(error)
                }
            })
            
            return task
        }
        
        result(nil)
    }

}

extension FreeRTOSBluetooth {
    
    @objc
    func deviceConnectedObserver(_ notification: Notification) throws {
        let uuid = notification.userInfo?["identifier"] as! UUID
        guard let peripheral = central?.retrievePeripherals(withIdentifiers: [uuid]).first else {
            throw FreeRTOSBluetoothError.deviceNotConnected
        }
        connectedPeripherals[peripheral.identifier] = peripheral
        central?.connect(peripheral, options: nil)
    }
    
    @objc
    func disconnectPeripheral(_ notification: Notification) throws {
        let uuid = notification.userInfo?["identifier"] as! UUID
        guard let peripheral = connectedPeripherals[uuid], peripheral.state == .connected else {
            throw FreeRTOSBluetoothError.deviceNotConnected
        }
        central?.cancelPeripheralConnection(peripheral)
//        connectedPeripherals.removeValue(forKey: peripheral.identifier)
    }
    
    // Helper functions
    func getAmazonFreeRTOSDevice(uuidString: String) -> AmazonFreeRTOSDevice? {
        guard let deviceUUID = UUID(uuidString: uuidString),
              let device = amazonFreeRTOSManager.devices[deviceUUID]
        else { return nil }
        
        return device
    }
}

extension FreeRTOSBluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        debugPrint("[FreeRTOSBluetooth] central state changed \(central.state)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        debugPrint("[FreeRTOSBluetooth] deviceConnectedPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("[FreeRTOSBluetooth] didDisconnectPeripheral")
        peripheral.delegate = nil
        connectedPeripherals.removeValue(forKey: peripheral.identifier)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("[FreeRTOSBluetooth didFailToConnect]")
        connectedPeripherals.removeValue(forKey: peripheral.identifier)
    }
    
}

extension FreeRTOSBluetooth: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.delegate = self
        for service in peripheral.services ?? [] {
            debugPrint("discoveredService: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        peripheral.delegate = self
        for characteristic in service.characteristics ?? [] {
            debugPrint("discoverCharacteristics: \(characteristic.uuid.uuidString)")
            // peripheral.setNotifyValue(true, for: characteristic)
            // TODO: Add descriptors
            // peripheral.discoverDescriptors(for: characteristic)
        }
        
        NotificationCenter.default.post(name: .flutterFreeRTOSPeripheralDidDiscoverCharacteristics, object: nil, userInfo: ["service": service, "peripheral": peripheral])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.delegate = self
        for descriptors in characteristic.descriptors ?? [] {
            debugPrint("discoverDescriptors: \(descriptors.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.delegate = self
        guard let value = characteristic.value, let stringValue = String(data: value, encoding: .utf8) else {
            debugPrint("invalid value for characteristic: \(characteristic.uuid.uuidString)")
            return
        }
        
        debugPrint("Notify characteristic: \(characteristic.uuid.uuidString), value: \(stringValue)")
    }
}
