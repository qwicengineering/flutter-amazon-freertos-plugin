package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice

/*
    iOS states:

    CBManagerState.poweredOff,
    CBManagerState.poweredOn,
    CBManagerState.resetting,
    CBManagerState.unauthorized,
    CBManagerState.unsupported,
    CBManagerState.unknown
*/

// TODO: Since the BLE state in Android is not the same as it is on iOS,
//  we need to find a better way to match these values:
//  BluetoothAdapter.STATE_OFF = 10
//  BluetoothAdapter.STATE_ON = 12
//  And we don't have an unknown state on Android

fun dumpBluetoothState(state: Int): Int {
    return when(state) {
        BluetoothAdapter.STATE_OFF -> 0
        BluetoothAdapter.STATE_ON -> 1
        else -> {
            5
        }
    }
}

// Device states in iOS
//val _deviceStateEnum = [
//    CBPeripheralState.connected,
//    CBPeripheralState.connecting,
//    CBPeripheralState.disconnected,
//    CBPeripheralState.disconnecting
//]

fun dumpFreeRTOSDeviceInfo(device: BluetoothDevice): Map<String, Any> {
    return mapOf(
        "id" to device.address,
        "name" to device.name,
        "state" to 2, // DISCONNECTED
        "reconnect" to false,
        "rssi" to 0,
        "certificateId" to "",
        "brokerEndpoint" to "",
        "mtu" to 0
    )
}