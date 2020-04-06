package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothManager
import android.content.Context
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import software.amazon.freertos.amazonfreertossdk.AmazonFreeRTOSManager


class FreeRTOSBluetooth(context: Context) {
    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    val awsFreeRTOSManager = AmazonFreeRTOSManager(context, bluetoothAdapter)!!
    val broadcaster: LocalBroadcastManager = LocalBroadcastManager.getInstance(context)

    fun bluetoothState(call: MethodCall, result: MethodChannel.Result) {
        result.success(dumpBluetoothState(bluetoothAdapter.state));
    }

}