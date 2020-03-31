package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSManager


class FreeRTOSBluetooth(context: Context) {
    val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    val bluetoothAdapter = bluetoothManager.adapter
    val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter)!!
    val broadcaster: LocalBroadcastManager = LocalBroadcastManager.getInstance(context)

    fun bluetoothState(call: MethodCall, result: MethodChannel.Result) {
        // TODO: match android states with iOS states to have values from 0-5
        result.success(BluetoothAdapter.STATE_DISCONNECTED);
    }

}