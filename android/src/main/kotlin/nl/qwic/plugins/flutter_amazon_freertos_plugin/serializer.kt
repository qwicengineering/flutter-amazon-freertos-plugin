package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice

/*
    CBManagerState.poweredOff,
    CBManagerState.poweredOn,
    CBManagerState.resetting,
    CBManagerState.unauthorized,
    CBManagerState.unsupported,
    CBManagerState.unknown
*/


fun dumpBluetoothState(state: BluetoothDevice): Int {
    return BluetoothAdapter.STATE_DISCONNECTED;
}