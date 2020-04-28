package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattService

inline fun <reified T> Any?.tryCast(block: T.() -> Unit) {
    if (this is T) {
        block()
    }
}

/*
    iOS states:
    CBManagerState.poweredOff,
    CBManagerState.poweredOn,
    CBManagerState.resetting,
    CBManagerState.unauthorized,
    CBManagerState.unsupported,
    CBManagerState.unknown
*/

fun dumpBluetoothState(state: Int): Int {
    return when(state) {
        BluetoothAdapter.STATE_OFF -> 0
        BluetoothAdapter.STATE_ON -> 1
        else -> {
            5
        }
    }
}

/*
    iOS device states:
    CBPeripheralState.connected,
    CBPeripheralState.connecting,
    CBPeripheralState.disconnected,
    CBPeripheralState.disconnecting
*/

fun dumpBluetoothDeviceState(state: Int): Int {
    return when(state) {
        2 -> 0 // BluetoothProfile.STATE_CONNECTED = 2 and has to match with 0
        0 -> 2 // BluetoothProfile.STATE_DISCONNECTED = 0 and has to match with 2
        else -> {
            2
        }
    };
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

fun dumpCharacteristicProperties(characteristic: BluetoothGattCharacteristic): Map<String, Boolean>{
    val properties = characteristic.properties
    val permissions = characteristic.permissions
    return mutableMapOf(
        "isReadable" to (properties and BluetoothGattCharacteristic.PROPERTY_READ != 0),
        "isWritableWithoutResponse" to (properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0),
        "isWritable" to (properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0),
        "isNotifying" to (properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0),
        "isIndicatable" to (properties and BluetoothGattCharacteristic.PROPERTY_INDICATE != 0),
        "allowsSignedWrites" to (properties and BluetoothGattCharacteristic.PROPERTY_SIGNED_WRITE != 0),
        "hasExtendedProperties" to (properties and BluetoothGattCharacteristic.PROPERTY_EXTENDED_PROPS != 0),
        "notifyEncryptionRequired" to (permissions and BluetoothGattCharacteristic.PERMISSION_READ_ENCRYPTED != 0),
        "indicateEncryptionRequired" to (permissions and BluetoothGattCharacteristic.PERMISSION_WRITE_ENCRYPTED != 0)
    )
}

fun dumpServiceCharacteristics(service: BluetoothGattService, deviceUUID: String): List<Map<String, Any>> {
    val result = mutableListOf<MutableMap<String, Any>>();
    service.characteristics.forEach() {
       result.add(
           mutableMapOf(
               "uuid" to it.uuid.toString(),
               "isNotifying" to (it.properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0),
               "value" to it.value,
               "serviceUUID" to it.service.uuid.toString(),
               "deviceUUID" to deviceUUID,
               "properties" to dumpCharacteristicProperties(it)
           )
       )
    }
    return result;
}

fun dumpFreeRTOSDeviceServiceInfo(service: BluetoothGattService, deviceUUID: String): Map<String, Any> {
    val primaryServiceMap: MutableMap<String, Any> = mutableMapOf(
            "uuid" to service.uuid.toString(),
            "isPrimary" to (service.type == BluetoothGattService.SERVICE_TYPE_PRIMARY),
            "deviceUUID" to deviceUUID,
            "characteristics" to dumpServiceCharacteristics(service, deviceUUID),
            "includedServices" to mutableListOf<Any>()
    )
    val includedServiceList = mutableListOf<Any>();
    val includedServices: Any = service.includedServices ?: primaryServiceMap

    if(includedServices is MutableMap<*,*>) {
        includedServices.tryCast<MutableMap<String, Any>> {
            includedServiceList.add(mutableListOf(
                    primaryServiceMap["uuid"],
                    primaryServiceMap["isPrimary"],
                    dumpServiceCharacteristics(service, deviceUUID)
            ))
        }
    } else {
        includedServices.tryCast<List<BluetoothGattService>> {
            this.forEach() {
                includedServiceList.add(mutableListOf(
                        it.uuid.toString(),
                        (service.type == BluetoothGattService.SERVICE_TYPE_PRIMARY),
                        dumpServiceCharacteristics(it, deviceUUID)
                ))
            }
        }
    }
    primaryServiceMap["includedServices"] = includedServiceList
    return primaryServiceMap
}
