import AmazonFreeRTOS
import CoreBluetooth


func dumpFreeRTOSDeviceInfo(_ device: AmazonFreeRTOSDevice) -> [String: Any] {
    let deviceState = _deviceStateEnum.firstIndex(of: device.peripheral.state)!

    return [
        "id": device.peripheral.identifier.uuidString,
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
    var primaryServiceMap: [String: Any] = ["id": service.uuid.uuidString, "isPrimary": service.isPrimary]
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
        let characteristicProperty = _characteristicPropertiesEnum.firstIndex(of: c.properties)
        result.append([
            "id": c.uuid.uuidString,
            "isNotifying": c.isNotifying,
            "property": characteristicProperty ?? -1,
            "value": c.value,
            "serviceId": c.service.uuid.uuidString,
        ])
    }
    return result
}

//func dumpBlueoothDescriptor(_ descriptor: CBDescriptor) -> [[String: Any]] {
//    return [
//        "id": descriptor.value
//    ]
//}

let _characteristicPropertiesEnum = [
    CBCharacteristicProperties.broadcast,
    CBCharacteristicProperties.read,
    CBCharacteristicProperties.writeWithoutResponse,
    CBCharacteristicProperties.write,
    CBCharacteristicProperties.notify,
    CBCharacteristicProperties.indicate,
    CBCharacteristicProperties.authenticatedSignedWrites,
    CBCharacteristicProperties.extendedProperties,
    CBCharacteristicProperties.notifyEncryptionRequired,
    CBCharacteristicProperties.indicateEncryptionRequired
]

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
