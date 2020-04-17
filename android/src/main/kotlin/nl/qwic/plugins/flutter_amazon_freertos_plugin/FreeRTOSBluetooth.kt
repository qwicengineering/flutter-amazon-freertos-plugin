package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanResult
import android.content.Context
import com.amazonaws.auth.AWSCredentialsProvider
import com.amazonaws.mobile.client.AWSMobileClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.*
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSConstants.BleConnectionState


/*
    methodMap: [
        "bluetoothState": plugin.bluetoothState,
        "startScanForDevices": plugin.startScanForDevices,
        "stopScanForDevices": plugin.stopScanForDevices,
        "rescanForDevices": plugin.rescanForDevices,
        "connectToDeviceId": plugin.connectToDeviceId,
        "disconnectFromDeviceId": plugin.disconnectFromDeviceId,
        "deviceState": plugin.deviceState,
        "deviceStateOnListen": plugin.deviceStateOnListen,
        "deviceStateOnCancel": plugin.deviceStateOnCancel,
        "listDiscoveredDevices": plugin.listDiscoveredDevices,
        "listServicesForDeviceId": plugin.listServicesForDevice,
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
    private val bluetoothDevices: MutableMap<String, BluetoothDevice> = mutableMapOf()
    private val freeRTOSDevices: MutableMap<String, Map<String, Any>> = mutableMapOf()
    var connectedDevice: AmazonFreeRTOSDevice? = null;
    var connectedDeviceStatus: AmazonFreeRTOSConstants.BleConnectionState = AmazonFreeRTOSConstants.BleConnectionState.BLE_DISCONNECTED;

    private fun scanDevices() {
        awsFreeRTOSManager.startScanDevices(
            object: BleScanResultCallback() {
                override fun onBleScanResult(scanResult: ScanResult) {
                    val device = scanResult.device;
                    if(!bluetoothDevices.contains(device.address)) {
                        bluetoothDevices[device.address] = device;
                        freeRTOSDevices[device.address] = dumpBlueToothDeviceInfo(device);
                    }
                }
                override fun onBleScanFailed(errorCode: Int) {
                    print(errorCode);
                }
            }, 0
        )
    }

    fun bluetoothState(call: MethodCall, result: MethodChannel.Result) {
        result.success(dumpBluetoothState(bluetoothAdapter.state));
    }

    // TODO: return found device on every scanResult
    fun startScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        scanDevices();
        result.success(null);
    }

    fun stopScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        awsFreeRTOSManager.stopScanDevices();
        result.success(null);
    }

    fun rescanForDevices(call: MethodCall, result: MethodChannel.Result) {
        awsFreeRTOSManager.stopScanDevices();
        bluetoothDevices.clear();
        freeRTOSDevices.clear();
        scanDevices();
        result.success(null)
    }

    fun listDiscoveredDevices(call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(freeRTOSDevices.values));
    }

    private val connectionStatusCallback: BleConnectionStatusCallback = object : BleConnectionStatusCallback() {
        override fun onBleConnectionStatusChanged(connectionStatus: BleConnectionState) {
            print("BLE connection status changed to: $connectionStatus");
            connectedDeviceStatus = connectionStatus;
        }
    }

    fun connectToDeviceId(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        val reconnect = call.argument<Boolean>("reconnect") ?: true;
        val device = bluetoothDevices[deviceUUID];
        if(device == null) {
            result.error("404", "No device found", null);
            return;
        }
        val credentialsProvider: AWSCredentialsProvider = AWSMobileClient.getInstance()
        connectedDevice = awsFreeRTOSManager.connectToDevice(device, connectionStatusCallback, credentialsProvider, reconnect)
        result.success(null);
    }

    fun deviceState(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        if(connectedDevice != null && connectedDevice?.mBluetoothDevice?.address === deviceUUID) {
            result.success(dumpBluetoothDeviceState(connectedDeviceStatus));
            return;
        }
        result.success(dumpBluetoothDeviceState(AmazonFreeRTOSConstants.BleConnectionState.BLE_DISCONNECTED));

    }

    fun disconnectFromDeviceId(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        if(connectedDevice != null) {
            awsFreeRTOSManager.disconnectFromDevice(connectedDevice!!);
        }
        result.success(null);
    }
}
