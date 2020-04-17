package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSConstants
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSDevice

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

private val deviceStateEnum = arrayOf(
    AmazonFreeRTOSConstants.BleConnectionState.BLE_CONNECTED,
    AmazonFreeRTOSConstants.BleConnectionState.BLE_CONNECTING,
    AmazonFreeRTOSConstants.BleConnectionState.BLE_DISCONNECTED,
    AmazonFreeRTOSConstants.BleConnectionState.BLE_DISCONNECTING
);

fun dumpBluetoothDeviceState(state: AmazonFreeRTOSConstants.BleConnectionState): Int {
    return deviceStateEnum.indexOf(state);
}

fun dumpBlueToothDeviceInfo(device: BluetoothDevice): Map<String, Any> {
    return mapOf(
        "uuid" to device.address,
        "name" to device.name,
        "state" to 2, // DISCONNECTED
        "reconnect" to false,
        "rssi" to 0,
        "certificateId" to "",
        "brokerEndpoint" to "",
        "mtu" to 0
    )
}
