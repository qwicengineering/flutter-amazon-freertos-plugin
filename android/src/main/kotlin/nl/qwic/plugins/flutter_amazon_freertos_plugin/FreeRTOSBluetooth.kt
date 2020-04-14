package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanResult
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSManager
import software.amazon.freertos.amazonfreertossdk.BleScanResultCallback


/*
* methodMap: [
    "bluetoothState": plugin.bluetoothState,
    "startScanForDevices": plugin.startScanForDevices,
    "stopScanForDevices": plugin.stopScanForDevices,
    "rescanForDevices": plugin.rescanForDevices,
    "connectToDeviceId": plugin.connectToDeviceId,
    "disconnectFromDeviceId": plugin.disconnectFromDeviceId,
    "discoverDevicesOnListen": plugin.discoverDevicesOnListen,
    "discoverDevicesOnCancel": plugin.discoverDevicesOnCancel,
    "listServices": plugin.listServices,
    "listDiscoveredDevices": plugin.listDiscoveredDevices,
    "readCharacteristic": plugin.readCharacteristic,
    "readDescriptor": plugin.readDescriptor,
    "writeDescriptor": plugin.writeDescriptor,
    "writeCharacteristic": plugin.writeCharacteristic,
    "setNotification": plugin.setNotification,
    "getMtu": plugin.getMtu,
    "setMtu": plugin.setMtu
]
* */

class FreeRTOSBluetooth(context: Context) {
    private val context = context;
    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter)!!
    private val devices: MutableMap<String, Map<String, Any>> = mutableMapOf()

    fun bluetoothState(call: MethodCall, result: MethodChannel.Result) {
        result.success(dumpBluetoothState(bluetoothAdapter.state));
    }

    // TODO: return found device on every scanResult
    fun startScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        awsFreeRTOSManager.startScanDevices(
            object: BleScanResultCallback() {
                override fun onBleScanResult(scanResult: ScanResult) {
                    val device = scanResult.device;
                    if(!devices.contains(device.address)) {
                        devices[device.address] = dumpFreeRTOSDeviceInfo(device);
                    }
                }
                override fun onBleScanFailed(errorCode: Int) {
                    print(errorCode);
                    result.success(errorCode);
                }
            }, 0
        )
        result.success(null);
    }

    fun stopScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        awsFreeRTOSManager.stopScanDevices();
        result.success(null);
    }

    fun rescanForDevices(call: MethodCall, result: MethodChannel.Result) {
        devices.clear();
        startScanForDevices(call, result);
        result.success(null)
    }

    fun listDiscoveredDevices(call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(devices.values));
    }

    // TODO: connect to a device
    // awsFreeRTOSManager.connectToDevice()
    // val awsDevice = AmazonFreeRTOSDevice(device, context, credentialsProvider)
}
