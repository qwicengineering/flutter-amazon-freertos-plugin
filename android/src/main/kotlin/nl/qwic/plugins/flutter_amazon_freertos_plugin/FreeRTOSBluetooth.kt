package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.*
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.amazonaws.auth.AWSCredentialsProvider
import com.amazonaws.mobile.client.AWSMobileClient
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSConstants.BleConnectionState
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSDevice
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
    private val TAG = "FreeRTOSBluetooth";
    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager;
    private val bluetoothAdapter = bluetoothManager.adapter;
    private val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter);
    private val bluetoothDevices: MutableMap<String, BluetoothDevice> = mutableMapOf();
    private val freeRTOSDevices: MutableMap<String, Map<String, Any>> = mutableMapOf();
    private val connectedDevices: MutableMap<String, AmazonFreeRTOSDevice> = mutableMapOf();
    private val bluetoothGattConnections: MutableMap<String, BluetoothGatt> = mutableMapOf();
    private var deviceStateReceiver: BroadcastReceiver? = null;

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
        try {
            scanDevices();
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun stopScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        try {
            awsFreeRTOSManager.stopScanDevices();
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun rescanForDevices(call: MethodCall, result: MethodChannel.Result) {
        try {
            awsFreeRTOSManager.stopScanDevices();
            bluetoothDevices.clear();
            freeRTOSDevices.clear();
            scanDevices();
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun listDiscoveredDevices(call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(freeRTOSDevices.values));
    }

    private val connectionStatusCallback: BleConnectionStatusCallback = object : BleConnectionStatusCallback() {
        override fun onBleConnectionStatusChanged(connectionStatus: BleConnectionState) {
            print("BLE connection status changed to: $connectionStatus");
        }
    }

    private val bluetoothGattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.i(TAG, "Connected to GATT server.");
                // Attempts to discover services after successful connection.
                val servicesDiscovered = gatt.discoverServices();
                Log.i(TAG, "Attempting to start service discovery: $servicesDiscovered");
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                gatt.disconnect();
                Log.i(TAG, "Disconnected from GATT server.");
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.w(TAG, "onServicesDiscovered received: $status");
            } else {
                Log.w(TAG, "onServicesDiscovered received: $status");
            }
        }

        override fun onCharacteristicRead(gatt: BluetoothGatt,
                                          characteristic: BluetoothGattCharacteristic,
                                          status: Int) {
            Log.w(TAG, "onCharacteristicRead status: $status");
            Log.w(TAG, "onCharacteristicRead read: $characteristic");
        }

        override fun onCharacteristicChanged(gatt: BluetoothGatt,
                                             characteristic: BluetoothGattCharacteristic) {
            Log.w(TAG, "onCharacteristicChanged read: $characteristic");
        }
    }

    fun connectToDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID");
            val reconnect = call.argument<Boolean>("reconnect") ?: true;
            val device = bluetoothDevices[deviceUUID];
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent");
                return;
            }
            if(device == null) {
                result.error("404", "Device not found", null);
                return;
            }
            val credentialsProvider: AWSCredentialsProvider = AWSMobileClient.getInstance();
            connectedDevices[device.address] = awsFreeRTOSManager.connectToDevice(device, connectionStatusCallback, credentialsProvider, reconnect);
            bluetoothGattConnections[device.address] = device.connectGatt(context, false, bluetoothGattCallback);
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun deviceState(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID");
            val connectedDevice = connectedDevices[deviceUUID];
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent");
                return;
            }
            if(connectedDevice == null) {
                result.success(dumpBluetoothDeviceState(BluetoothProfile.STATE_DISCONNECTED));
                return;
            }
            val state = bluetoothManager.getConnectionState(connectedDevice.mBluetoothDevice, BluetoothProfile.GATT);
            result.success(dumpBluetoothDeviceState(state));
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun deviceStateOnListen(id: Int, args: Any?, sink: EventChannel.EventSink) {
        try {
        val deviceUUID = args  as String;
            val device = bluetoothDevices[deviceUUID];
            if(deviceUUID == null) {
                sink.error("404", "deviceUUID param", "deviceUUID param should be sent");
                return;
            }
            if(device == null) {
                sink.error("500", "device not found", "There's no device with the given deviceUUID param");
                return;
            }
            deviceStateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    val state = bluetoothManager.getConnectionState(device, BluetoothProfile.GATT);
                    sink.success(dumpBluetoothDeviceState(state));
                }
            }
            val filter = IntentFilter();
            filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
            filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
            context.registerReceiver(deviceStateReceiver, filter);
        } catch(error: Exception) {
            sink.error("500", error.message, error);
        }
    }

    fun deviceStateOnCancel(id: Int, args: Any?) {
        if(deviceStateReceiver == null) return;
        context.unregisterReceiver(deviceStateReceiver);
    }

    fun disconnectFromDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID");
            val connectedDevice = connectedDevices[deviceUUID];
            val gattConnection = bluetoothGattConnections[deviceUUID];
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent");
                return;
            }
            if(connectedDevice == null || gattConnection == null) {
                result.error("500", "device not found", "There's no connected device with the given deviceUUID param");
                return;
            }
            awsFreeRTOSManager.disconnectFromDevice(connectedDevice);
            gattConnection.disconnect();
            connectedDevices.remove(deviceUUID);
            bluetoothGattConnections.remove(deviceUUID);
            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }

    fun listServicesForDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID");
            val gattConnection = bluetoothGattConnections[deviceUUID];
            val services: MutableList<Any> = mutableListOf();
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent");
                return;
            }
            if(gattConnection == null) {
                result.error("500", "GATT Connection not found", "There's no GATT connection with the given deviceUUID param");
                return;
            }
            /*
                This only will have discovered services when gatt.discoverServices() completes successfully
                Check inside bluetoothGattCallback
            */
            gattConnection.services.forEach {
                services.add(dumpFreeRTOSDeviceServiceInfo(it, deviceUUID));
            }
            result.success(services);
        } catch(error: Exception) {
            result.error("500", error.message, error);
        }
    }
}
