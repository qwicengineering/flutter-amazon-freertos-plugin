//
//  FreeRTOSBluetoothScan.swift
//  flutter_amazon_freertos_plugin
//
//  Created by Sri Majji on 6/12/20.
//

import CoreBluetooth


class FreeRTOSBluetoothScan: NSObject {
    let amazonFreeRTOSManager: AmazonFreeRTOSManager
    var scanForDevicesObserver: NSObjectProtocol?
    
    init(_ amazonFreeRTOSManager: AmazonFreeRTOSManager) {
        self.amazonFreeRTOSManager = amazonFreeRTOSManager
        super.init()
    }
    
    func _setupScanNotifications(id: Int, sink: @escaping FlutterEventSink) {
        scanForDevicesObserver = NotificationCenter.default.addObserver(forName: .afrCentralManagerDidDiscoverDevice, object: nil, queue: nil)
        { notification in
                let notificationDeviceUUID = notification.userInfo?["identifier"] as! UUID
            guard let device = self.amazonFreeRTOSManager.devices[notificationDeviceUUID] else { return }
                debugPrint("[FreeRTOSBluetooth] sendDiscoveredDeviceInfo deviceUUID: \(notificationDeviceUUID)")
                sink(dumpFreeRTOSDeviceInfo(device))
        }
    }
    
    func _removeScanNotifications() {
        guard scanForDevicesObserver != nil else { return }
        NotificationCenter.default.removeObserver(scanForDevicesObserver)
    }
    
    func startScanForDevicesOnListen(id: Int, args: Any?, sink: @escaping FlutterEventSink) {
        let map = args as! [String: Any?]
        let scanDuration = map["scanDuration"] as? Int ?? 0
        var advertisingServiceUUIDs: [CBUUID] = amazonFreeRTOSManager.advertisingServiceUUIDs
        if let customServiceUUIDs = map["serviceUUIDS"] as? [CBUUID] {
           advertisingServiceUUIDs += customServiceUUIDs
        }
        
        // clear existing scan and notification observers
        amazonFreeRTOSManager.central?.stopScan()
        _removeScanNotifications()
        
        // setup notification observer and start scan
        _setupScanNotifications(id: id, sink: sink)
        amazonFreeRTOSManager.central?.scanForPeripherals(withServices: advertisingServiceUUIDs, options: nil)
        
        debugPrint("[FreeRTOSBluetooth] startScanForDevicesOnListen id: \(id), advertisingUUIDs: \(advertisingServiceUUIDs) scanDuration:\(scanDuration) startStream")
        // Do not end stream if scanDuration is 0
        if scanDuration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(scanDuration)) {
                sink(FlutterEndOfEventStream)
            }
        }
    }
    
    func startScanForDevicesOnCancel(id: Int, args: Any?) {
        _removeScanNotifications()
        amazonFreeRTOSManager.central?.stopScan()
        debugPrint("[FreeRTOSBluetooth] startScanForDevicesOnCancel id: \(id) cancelStream")
    }
    
    func stopScanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let central = amazonFreeRTOSManager.central, central.isScanning else {
            debugPrint("[FreeRTOSBluetoothScan] stopScanForDevices scan not in progress")
            return
        }
        
        _removeScanNotifications()
        central.stopScan()
        
        debugPrint("[FreeRTOSBluetoothScan] stopScanForDevices stop scan")
        result(nil)
    }
    
    func rescanForDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
    
}
