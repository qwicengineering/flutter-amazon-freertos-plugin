package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanResult
import android.content.Context
import com.amazonaws.auth.AWSCredentialsProvider
import com.amazonaws.mobile.client.AWSMobileClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSConstants.BleConnectionState
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSManager
import software.amazon.freertos.amazonfreertossdk.BleConnectionStatusCallback
import software.amazon.freertos.amazonfreertossdk.BleScanResultCallback


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

    private fun scanDevices() {
        awsFreeRTOSManager.startScanDevices(
            object: BleScanResultCallback() {
                override fun onBleScanResult(scanResult: ScanResult) {
                    val device = scanResult.device;
                    if(!bluetoothDevices.contains(device.address)) {
                        bluetoothDevices[device.address] = device;
                        freeRTOSDevices[device.address] = dumpFreeRTOSDeviceInfo(device);
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
            if (connectionStatus == BleConnectionState.BLE_CONNECTED) {

            } else if (connectionStatus == BleConnectionState.BLE_DISCONNECTED) {

            }
        }
    }

    fun connectToDeviceId(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        val device = bluetoothDevices[deviceUUID];
        if(device != null) {
            val credentialsProvider: AWSCredentialsProvider = AWSMobileClient.getInstance()
            val aDevice = awsFreeRTOSManager.connectToDevice(device, connectionStatusCallback, credentialsProvider, true)
            result.success(aDevice);
        }
        result.error("404", "No device found", null);
    }

    fun deviceState(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID");
        print("deviceUUID");
        print(deviceUUID);
        result.success(2);
    }
    /*
    * func connectToDeviceId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceId = args["deviceUUID"] as! String
        let reconnect = args["reconnect"] as? Bool ?? true

        guard let deviceUUID = UUID(uuidString: deviceId) else { return }
        if let device = awsFreeRTOSManager.devices[deviceUUID] {
            device.connect(reconnect: reconnect, credentialsProvider: AWSMobileClient.default())
        }
    }
    *
    * func deviceState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let deviceUUIDString = args["deviceUUID"] as! String

        guard let device = getDevice(uuidString: deviceUUIDString) else { return }
        result(dumpDeviceState(device.peripheral.state))
    }
    * */
}
