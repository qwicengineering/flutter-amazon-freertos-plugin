package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.*
import android.bluetooth.le.ScanResult
import android.content.Context
import com.amazonaws.auth.AWSCredentialsProvider
import com.amazonaws.mobile.client.AWSMobileClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.*
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSConstants.BleConnectionState
import java.lang.Exception

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
    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter)!!
    private val bluetoothDevices: MutableMap<String, BluetoothDevice> = mutableMapOf()
    private val freeRTOSDevices: MutableMap<String, Map<String, Any>> = mutableMapOf()
    private val connectedDevices: MutableMap<String, AmazonFreeRTOSDevice> = mutableMapOf()
    private val context = context;

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
        }
    }

    fun connectToDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID");
            val reconnect = call.argument<Boolean>("reconnect") ?: true;
            val device = bluetoothDevices[deviceUUID];
            if(device == null) {
                result.error("404", "No device found", null);
                return;
            }
            val credentialsProvider: AWSCredentialsProvider = AWSMobileClient.getInstance()
            connectedDevices[device.address] = awsFreeRTOSManager.connectToDevice(device, connectionStatusCallback, credentialsProvider, reconnect)
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }

    }

    fun deviceState(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        if(connectedDevices.isNotEmpty() && connectedDevices[deviceUUID] != null ) {
            val state = bluetoothManager.getConnectionState(connectedDevices[deviceUUID]?.mBluetoothDevice, BluetoothProfile.GATT);
            result.success(dumpBluetoothDeviceState(state));
            return;
        }
        result.success(dumpBluetoothDeviceState(BluetoothProfile.STATE_DISCONNECTED));

    }

    fun disconnectFromDeviceId(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        if(deviceUUID != null && connectedDevices.isNotEmpty() && connectedDevices[deviceUUID] != null) {
            awsFreeRTOSManager.disconnectFromDevice(connectedDevices[deviceUUID]!!);
        }
        result.success(null);
    }

    private val bluetoothGattCallback: BluetoothGattCallback = object : BluetoothGattCallback() {
        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            print("hey $gatt");
            print("status: $status")
        }
    }

    fun listServicesForDeviceId(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        if(deviceUUID == null) {
            result.error("404", "deviceUUID param", "deviceUUID param should be sent")
        }
        val device = connectedDevices[deviceUUID];
        val gattConnection = device?.mBluetoothDevice?.connectGatt(context, true, bluetoothGattCallback)

        gattConnection?.services?.forEach {
            dumpFreeRTOSDeviceServiceInfo(it);
        }
        result.success(gattConnection?.services)
    }

    /*
    * func listServicesForDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any?] else { return }

        let deviceUUIDString = args["deviceUUID"] as! String
        guard let device = getDevice(uuidString: deviceUUIDString) else { return }

        var services: [Any] = []
        for service in device.peripheral.services ?? [] {
            services.append(dumpFreeRTOSDeviceServiceInfo(service))
        }
        result(services)
    }*/
}
