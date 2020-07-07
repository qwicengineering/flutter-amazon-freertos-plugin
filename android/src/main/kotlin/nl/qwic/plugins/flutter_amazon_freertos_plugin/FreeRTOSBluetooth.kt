package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.*
import android.bluetooth.BluetoothGattCharacteristic.PROPERTY_READ
import android.bluetooth.BluetoothProfile.GATT
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
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
import java.lang.reflect.Method
import java.util.*
import kotlin.collections.ArrayList


class FreeRTOSBluetooth(context: Context) {
    private val context = context
    private val TAG = "FreeRTOSBluetooth"
    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter)
    private val bluetoothDevices: MutableMap<String, BluetoothDevice> = mutableMapOf()
    private val freeRTOSDevices: MutableMap<String, Map<String, Any>> = mutableMapOf()
    private val connectedDevices: MutableMap<String, AmazonFreeRTOSDevice> = mutableMapOf()
    private val bluetoothGattConnections: MutableMap<String, BluetoothGatt> = mutableMapOf()
    private var deviceStateReceiver: BroadcastReceiver? = null
    private val CUSTOM_ACTION_DISCOVERED_SERVICES = "com.qwic.DiscoverServices"

    // Run code in the main UI Thread
    inline fun runOnUiThread(crossinline action: () -> Unit) {
        val mainLooper = Looper.getMainLooper()
        if(Looper.myLooper() == mainLooper) {
            action();
        } else {
            Handler(mainLooper).post { action() }
        }
    }

    // Force to refresh device cache
    private fun refreshDeviceCache(gatt: BluetoothGatt) {
        try {
            val localMethod: Method = gatt.javaClass.getMethod("refresh")
            localMethod.invoke(gatt)
        } catch (localException: java.lang.Exception) {
            Log.d("Exception", localException.toString())
        }
    }

    // Force to unpair device
    private fun removeBond(device: BluetoothDevice?) {
        try {
            if (device == null) {
                throw java.lang.Exception()
            }
            val method: Method = device.javaClass.getMethod("removeBond")
            method.invoke(device);
            Log.d(TAG, "removeBond() called")
            Thread.sleep(600)
            Log.d(TAG, "removeBond() - finished method")
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            Log.e(TAG, e.printStackTrace().toString())
        }
    }

    // Method used by startScanForDevicesOnListen() and rescanForDevicesOnListen()
    private fun scanDevices(scanDuration: Long, sink: EventChannel.EventSink) {
        bluetoothDevices.clear();
        freeRTOSDevices.clear();
        awsFreeRTOSManager.startScanDevices(
            object: BleScanResultCallback() {
                override fun onBleScanResult(scanResult: ScanResult) {
                    val device = scanResult.device
                    if(!bluetoothDevices.contains(device.address)) {
                        bluetoothDevices[device.address] = device
                        freeRTOSDevices[device.address] = dumpBlueToothDeviceInfo(device)
                        sink.success(dumpBlueToothDeviceInfo(device));
                    }
                }
                override fun onBleScanFailed(errorCode: Int) {
                    Log.e(TAG, errorCode.toString())
                    sink.error(errorCode.toString(), "Error in onBleScan method", "")
                }
            }, scanDuration
        )

        // Ends the stream if scanDuration is sent
        // (Using a timer since I don't find an 'onDone' callback in awd sdk)
        if(scanDuration > 0) {
            val timer = Timer("endStreamOnScanDuration", true);
            timer.schedule(object: TimerTask() {
                override fun run() {
                    sink.endOfStream();
                }
            } ,scanDuration)
        }
    }

    // *** Plugin Method's callbacks *** //

    private val connectionStatusCallback: BleConnectionStatusCallback = object : BleConnectionStatusCallback() {
        override fun onBleConnectionStatusChanged(connectionStatus: BleConnectionState) {
            Log.i(TAG,"BLE connection status changed to: $connectionStatus")
        }
    }

    private val bluetoothGattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.i(TAG, "Connected to GATT client. Attempting to start service discovery");
                // TODO: check what is the best value to send here and if still necessary
                // gatt.requestMtu(510);

                // This is needed to avoid connection problems
                // (https://stackoverflow.com/questions/20069507/gatt-callback-fails-to-register)
                try {
                    Thread.sleep(600)
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                    Log.e(TAG, e.printStackTrace().toString())
                }

            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.i(TAG, "Disconnected from GATT client");
                gatt.disconnect();
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            // TODO: Not sure if runOnUiThread is needed
            runOnUiThread {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    // It notifies that services are successfully discovered
                    val intent = Intent();
                    intent.action = CUSTOM_ACTION_DISCOVERED_SERVICES;
                    context.sendBroadcast(intent);
                    Log.w(TAG, "onServicesDiscovered received: $status");
                } else {
                    Log.e(TAG, "Service discovery failed $status");
                    Log.w(TAG, "onServicesDiscovered received: $status");
                }
            }
        }

        override fun onCharacteristicRead(gatt: BluetoothGatt,
                                          characteristic: BluetoothGattCharacteristic,
                                          status: Int) {
            Log.w(TAG, "onCharacteristicRead value: ${characteristic.value}");
            Log.w(TAG, "onCharacteristicRead read: $characteristic");
        }

        override fun onCharacteristicChanged(gatt: BluetoothGatt,
                                             characteristic: BluetoothGattCharacteristic) {
            Log.w(TAG, "onCharacteristicChanged read: ${characteristic.value}");
        }

        override fun onCharacteristicWrite(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?, status: Int) {
            super.onCharacteristicWrite(gatt, characteristic, status)
            Log.w(TAG, "onCharacteristicWrite write: $characteristic");
        }

        override fun onMtuChanged(gatt: BluetoothGatt?, mtu: Int, status: Int) {
            super.onMtuChanged(gatt, mtu, status)
            Log.w(TAG, "onMtuChanged status: $status");
            Log.w(TAG, "onMtuChanged gatt: $gatt");
            Log.w(TAG, "onMtuChanged mtu: $mtu");
        }
    }

    // *** Plugin Methods *** //

    fun bluetoothState(call: MethodCall, result: MethodChannel.Result) {
        result.success(dumpBluetoothState(bluetoothAdapter.state))
    }

    fun startScanForDevicesOnListen(id: Int, args: Any?, sink: EventChannel.EventSink) {
        try {
            val map = args as Map<*, *>
            val scanDuration = (map["scanDuration"] as Int).toLong()
            scanDevices(scanDuration, sink);
        } catch(error: Exception) {
            sink.error("500", error.message, error)
        }
    }

    fun startScanForDevicesOnCancel(id: Int, args: Any?) {
        // This method is triggered once sink.endOfStream() is run
    }

    fun stopScanForDevices(call: MethodCall, result: MethodChannel.Result) {
        try {
            awsFreeRTOSManager.stopScanDevices()
            result.success(null)
        } catch(error: Exception) {
            result.error("500", error.message, error)
        }
    }

    fun rescanForDevicesOnListen(id: Int, args: Any?, sink: EventChannel.EventSink   ) {
        try {
            val map = args as Map<*, *>
            val scanDuration = (map["scanDuration"] as Int).toLong()
            awsFreeRTOSManager.stopScanDevices()
            scanDevices(scanDuration, sink)
        } catch(error: Exception) {
            sink.error("500", error.message, error)
        }
    }

    fun rescanForDevicesOnCancel(id: Int, args: Any?) {
        // This method is triggered once sink.endOfStream() is run
    }

    fun listDiscoveredDevices(call: MethodCall, result: MethodChannel.Result) {
        result.success(ArrayList(freeRTOSDevices.values))
    }

    fun connectToDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID")
            val reconnect = call.argument<Boolean>("reconnect") ?: true
            val device = bluetoothDevices[deviceUUID]
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent")
                return
            }
            if(device == null) {
                result.error("404", "Device not found", null)
                return
            }

            // Recommended to run this code in the main thread to avoid issues
            runOnUiThread {
                // **** IMPORTANT ***** //
                // Device should be unpaired before connecting, otherwise callbacks won't work properly (we should unpair the device when disconnect)
                // If device is still paired before connecting, then gatt.discoverServices() won't work
                val credentialsProvider: AWSCredentialsProvider = AWSMobileClient.getInstance()
                connectedDevices[device.address] = awsFreeRTOSManager.connectToDevice(device, connectionStatusCallback, credentialsProvider, reconnect)
                removeBond(device);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bluetoothGattConnections[device.address] = device.connectGatt(context, false, bluetoothGattCallback, BluetoothDevice.TRANSPORT_LE)
                } else {
                    bluetoothGattConnections[device.address] = device.connectGatt(context, false, bluetoothGattCallback)
                }

                // Refresh device cache to avoid issues with it's services
                refreshDeviceCache(bluetoothGattConnections[device.address]!!);
            }

            result.success(null)
        } catch(error: Exception) {
            result.error("500", error.message, error)
        }
    }

    fun discoverServices(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID")
            val gattConnection = bluetoothGattConnections[deviceUUID]

            if(gattConnection == null) {
                result.error("500", "GATT Connection not found", "There's no GATT connection with the given deviceUUID param")
                return
            }

            // Seems to be working now thanks to the runOnUiThread, sleep, removeBond and clearCache
            // Refs: https://stackoverflow.com/questions/20069507/gatt-callback-fails-to-register
            // https://stackoverflow.com/questions/41434555/onservicesdiscovered-never-called-while-connecting-to-gatt-server
            if(!gattConnection.discoverServices()) {
                Log.e(TAG, "Error: Services are not discovered")
            }

            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error)
        }
    }

    fun discoverServicesOnListen(id: Int, args: Any?, sink: EventChannel.EventSink) {
        try {
            val map = args as Map<*, *>
            val deviceUUID = map["deviceUUID"] as String
            val gattConnection = bluetoothGattConnections[deviceUUID]
            val services: MutableList<Any> = mutableListOf()

            // Recommended to run this code in the main thread to avoid issues
            runOnUiThread {
                // When onServicesDiscovered() callback is run, it notifies and this listen to it
                val mReceiver: BroadcastReceiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context, intent: Intent) {
                        val action = intent.action
                        if (CUSTOM_ACTION_DISCOVERED_SERVICES == action && gattConnection != null) {
                            gattConnection.services.forEach {
                                services.add(dumpFreeRTOSDeviceServiceInfo(it, deviceUUID))
                                sink.success(dumpFreeRTOSDeviceServiceInfo(it, deviceUUID));
                            }
                        }
                        sink.endOfStream();
                    }
                }
                val filter = IntentFilter(CUSTOM_ACTION_DISCOVERED_SERVICES);
                context.registerReceiver(mReceiver, filter)
            }

        } catch(error: Exception) {
            Log.e(TAG, error.message);
            sink.error("500", error.message, error)
        }
    }

    fun discoverServicesOnCancel(id: Int, args: Any?) {
        // This method is triggered once sink.endOfStream() is run
    }

    fun deviceState(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID")
            val connectedDevice = connectedDevices[deviceUUID]
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent")
                return
            }
            if(connectedDevice == null) {
                result.success(dumpBluetoothDeviceState(BluetoothProfile.STATE_DISCONNECTED))
                return
            }
            // TODO: not sure if runOnUiThread is needed
            runOnUiThread {
                val state = bluetoothManager.getConnectionState(connectedDevice.mBluetoothDevice, GATT)
                result.success(dumpBluetoothDeviceState(state))
            }

        } catch(error: Exception) {
            result.error("500", error.message, error)
        }
    }

    fun deviceStateOnListen(id: Int, args: Any?, sink: EventChannel.EventSink) {
        try {
            val deviceUUID = args as String
            val device = bluetoothDevices[deviceUUID]

            if(deviceUUID == null) {
                sink.error("404", "deviceUUID param", "deviceUUID param should be sent")
                return
            }
            if(device == null) {
                sink.error("500", "device not found", "There's no device with the given deviceUUID param")
                return
            }

            // TODO: not sure if runOnUiThread is needed
            runOnUiThread {
                // This listen to any device state changes
                deviceStateReceiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context, intent: Intent) {
                        val bondState = device.bondState;
                        val state = bluetoothManager.getConnectionState(device, GATT)

                        if(state == BluetoothGatt.STATE_CONNECTED) {
                            when (bondState) {
                                BluetoothDevice.BOND_BONDED -> {
                                    sink.success(dumpBluetoothDeviceState(BluetoothGatt.STATE_CONNECTED))
                                }
                                BluetoothDevice.BOND_BONDING -> {
                                    sink.success(dumpBluetoothDeviceState(BluetoothGatt.STATE_CONNECTING))
                                }
                                else -> {
                                    sink.success(dumpBluetoothDeviceState(BluetoothGatt.STATE_DISCONNECTED))
                                }
                            }
                        } else {
                            sink.success(dumpBluetoothDeviceState(state))
                        }
                    }
                }
                val filter = IntentFilter()
                filter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
                filter.addAction(BluetoothGatt.EXTRA_STATE)

                context.registerReceiver(deviceStateReceiver, filter)
            }

        } catch(error: Exception) {
            sink.error("500", error.message, error)
        }
    }

    fun deviceStateOnCancel(id: Int, args: Any?) {
        if(deviceStateReceiver == null) return
        // TODO: not sure if runOnUiThread is needed
        runOnUiThread {
            context.unregisterReceiver(deviceStateReceiver)
        }
    }

    fun disconnectFromDeviceId(call: MethodCall, result: MethodChannel.Result) {
        try {
            val deviceUUID = call.argument<String>("deviceUUID")
            val connectedDevice = connectedDevices[deviceUUID]
            val gattConnection = bluetoothGattConnections[deviceUUID]
            val bleDevice = bluetoothDevices[deviceUUID];
            if(deviceUUID == null) {
                result.error("404", "deviceUUID param", "deviceUUID param should be sent")
                return
            }
            if(connectedDevice == null || gattConnection == null) {
                result.error("500", "device not found", "There's no connected device with the given deviceUUID param")
                return
            }
            // Recommended to run in the main UI Thread
            runOnUiThread {
                awsFreeRTOSManager.disconnectFromDevice(connectedDevice);
                removeBond(bleDevice);
                refreshDeviceCache(gattConnection)
                gattConnection.disconnect();
                gattConnection.close();
                bluetoothDevices.remove(deviceUUID);
                connectedDevices.remove(deviceUUID);
                bluetoothGattConnections.remove(deviceUUID);
            }

            result.success(null);
        } catch(error: Exception) {
            result.error("500", error.message, error)
        }
    }

    // TODO: test this with the new refactoring
    fun writeCharacteristic(call: MethodCall, result: MethodChannel.Result) {
        val value = call.argument<ByteArray>("value")
        val deviceUUID = call.argument<String>("deviceUUID")
        val serviceUUID = call.argument<String>("serviceUUID")
        val characteristicUUID = call.argument<String>("characteristicUUID")

        if (deviceUUID == null) {
            result.error("404", "deviceUUID param", "deviceUUID param should be sent")
            return
        }

        if (serviceUUID == null) {
            result.error("404", "serviceUUID param", "serviceUUID param should be sent")
            return
        }

        if (characteristicUUID == null) {
            result.error("404", "characteristicUUID param", "characteristicUUID param should be sent")
            return
        }

        if (value == null) {
            result.error("404", "value param", "value param should be sent")
            return
        }

        val gattConnection = bluetoothGattConnections[deviceUUID];

        if (gattConnection === null) {
            result.error("404", "gattConnection", "gattConnection not found")
            return
        }

        val service = gattConnection.getService(UUID.fromString(serviceUUID))

        if (service === null) {
            result.error("404", "service: $serviceUUID", "service not found")
            return
        }

        val characteristic = service.getCharacteristic(UUID.fromString(characteristicUUID))

        if (characteristic === null) {
            result.error("404", "characteristic: $characteristicUUID", "characteristic not found")
            return
        }

        // TODO: not sure if runOnUiThread is needed
        runOnUiThread {
            characteristic.setValue(value);
            gattConnection.writeCharacteristic(characteristic);
        }
    }

    // TODO: test this with the new refactoring
    fun readCharacteristic(call: MethodCall, result: MethodChannel.Result) {
        val deviceUUID = call.argument<String>("deviceUUID")
        val serviceUUID = call.argument<String>("serviceUUID")
        val characteristicUUID = call.argument<String>("characteristicUUID")

        if (deviceUUID == null) {
            result.error("404", "deviceUUID param", "deviceUUID param should be sent")
            return
        }

        if (serviceUUID == null) {
            result.error("404", "serviceUUID param", "serviceUUID param should be sent")
            return
        }

        if (characteristicUUID == null) {
            result.error("404", "characteristicUUID param", "characteristicUUID param should be sent")
            return
        }

        val gattConnection = bluetoothGattConnections[deviceUUID];

        if (gattConnection === null) {
            result.error("404", "gattConnection", "gattConnection not found")
            return
        }

        val service = gattConnection.getService(UUID.fromString(serviceUUID))

        if (service === null) {
            result.error("404", "service: $serviceUUID", "service not found")
            return
        }

        val characteristic = service.getCharacteristic(UUID.fromString(characteristicUUID))

        if (characteristic === null) {
            result.error("404", "characteristic: $characteristicUUID", "characteristic not found")
            return
        }

        // Check if this characteristic actually has READ property
        if (characteristic.properties and PROPERTY_READ == 0) {
            Log.e(TAG, "ERROR: Characteristic cannot be read")
            return
        }

        // TODO: not sure if runOnUiThread is needed
        runOnUiThread {
            result.success(gattConnection.readCharacteristic(characteristic));
        }

    }
}
