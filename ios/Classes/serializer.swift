import AmazonFreeRTOS
import CoreBluetooth


func dumpFreeRTOSDeviceInfo(_ device: AmazonFreeRTOSDevice) -> [Any] {
    let deviceState = _deviceStateEnum.firstIndex(of: device.peripheral.state)!

    return [
        device.peripheral.identifier.uuidString,
        device.advertisementData?["kCBAdvDataLocalName"] as? String ?? device.peripheral.name,
        deviceState,
        device.reconnect,
        device.RSSI?.intValue ?? 0,
        device.certificateId ?? "",
        device.brokerEndpoint ?? "",
        device.mtu ?? 0,
    ]
}

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
