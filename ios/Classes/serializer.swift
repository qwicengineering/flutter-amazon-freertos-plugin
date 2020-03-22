import AmazonFreeRTOS
import CoreBluetooth


func dumpFreeRTOSDeviceInfo(_ device: AmazonFreeRTOSDevice) -> [Any] {
    return [
        device.peripheral.identifier.uuidString,
        device.advertisementData?["kCBAdvDataLocalName"] as? String ?? device.peripheral.name,
        device.peripheral.state.rawValue,
        device.reconnect,
        device.RSSI?.stringValue ?? "0",
        device.certificateId ?? "",
        device.brokerEndpoint ?? "",
        device.mtu ?? 0
    ]
}

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
