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
        
    func connectToDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["id"] as! String
        let reconnect = args["reconnect"] as? Bool ?? true
        
        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device = awsFreeRTOSManager.devices[deviceUUID] {
            device.connect(reconnect: reconnect, credentialsProvider: AWSMobileClient.default())
        }
    }
    
    func disconnectFromDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["id"] as! String
        
        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device = awsFreeRTOSManager.devices[deviceUUID] {
            device.disconnect()
        }
    }
    
    func listServicesForDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["id"] as! String
        
        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device: AmazonFreeRTOSDevice = awsFreeRTOSManager.devices[deviceUUID] {
            var services: [Any] = []
            for service in device.peripheral.services ?? [] {
                services.append(dumpFreeRTOSDeviceServiceInfo(service))
            }
            result(services)
        }
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
    
}
