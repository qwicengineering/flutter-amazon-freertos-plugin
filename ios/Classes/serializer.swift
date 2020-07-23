import AmazonFreeRTOS
import CoreBluetooth


func dumpFreeRTOSDeviceInfo(_ device: AmazonFreeRTOSDevice) -> [String: Any] {
    let deviceState = _deviceStateEnum.firstIndex(of: device.peripheral.state)!

    return [
        "uuid": device.peripheral.identifier.uuidString,
        "name": device.advertisementData?["kCBAdvDataLocalName"] as? String ?? device.peripheral.name!,
        "state": deviceState,
        "reconnect": device.reconnect,
        "rssi": device.RSSI?.intValue ?? 0,
        "certificateId": device.certificateId ?? "",
        "brokerEndpoint": device.brokerEndpoint ?? "",
        "mtu": device.mtu ?? 0,
    ]
}

func dumpFreeRTOSDeviceServiceInfo(_ service: CBService) -> [String: Any] {
    var primaryServiceMap: [String: Any] = ["uuid": service.uuid.uuidString, "isPrimary": service.isPrimary, "deviceUUID": service.peripheral.identifier.uuidString]
    primaryServiceMap["characteristics"] = dumpServiceCharacteristics(service)
    primaryServiceMap["includedServices"] = []

    // Loop through included services if exists
    var includedServiceList: [Any] = []
    guard let includedServices = service.includedServices else { return primaryServiceMap }
    for s in includedServices {
        includedServiceList.append([s.uuid.uuidString, s.isPrimary, dumpServiceCharacteristics(s)])
    }
    primaryServiceMap["includedServices"] = includedServiceList

    return primaryServiceMap
}

func dumpServiceCharacteristics(_ service: CBService) -> [[String: Any]] {
    var result: [[String: Any]] = []
    for c in service.characteristics ?? [] {
        result.append([
            "uuid": c.uuid.uuidString,
            "isNotifying": c.properties.contains([.notify]),
            "value": c.value,
            "serviceUUID": c.service.uuid.uuidString,
            "deviceUUID": c.service.peripheral.identifier.uuidString,
            "properties": dumpCharacteristicProperties(c),
        ])
    }
    return result
}

func dumpCharacteristicProperties(_ charactertistic: CBCharacteristic) -> [String: Bool] {
    let properties = charactertistic.properties
    return [
        "isReadable": properties.contains([.read]),
        "isWritableWithoutResponse": properties.contains([.writeWithoutResponse]),
        "isWritable": properties.contains([.write]),
        "isNotifying": properties.contains([.notify]),
        "isIndicatable": properties.contains([.indicate]),
        "allowsSignedWrites": properties.contains([.authenticatedSignedWrites]),
        "hasExtendedProperties": properties.contains([.extendedProperties]),
        "notifyEncryptionRequired": properties.contains([.notifyEncryptionRequired]),
        "indicateEncryptionRequired": properties.contains([.indicateEncryptionRequired])
    ]
}

//func dumpBlueoothDescriptor(_ descriptor: CBDescriptor) -> [[String: Any]] {
//    return [
//        "id": descriptor.value
//    ]
//}

let _deviceStateEnum = [
    CBPeripheralState.connected,
    CBPeripheralState.connecting,
    CBPeripheralState.disconnected,
    CBPeripheralState.disconnecting
]

let _bluetoothStateEnum = [
    CBManagerState.poweredOff,
    CBManagerState.poweredOn,
    CBManagerState.resetting,
    CBManagerState.unauthorized,
    CBManagerState.unsupported,
    CBManagerState.unknown
]

func dumpBluetoothState(_ state: CBManagerState) -> Int {
    return _bluetoothStateEnum.firstIndex(of: state)!
}

func dumpDeviceState(_ state: CBPeripheralState) -> Int {
    return _deviceStateEnum.firstIndex(of: state)!
}
