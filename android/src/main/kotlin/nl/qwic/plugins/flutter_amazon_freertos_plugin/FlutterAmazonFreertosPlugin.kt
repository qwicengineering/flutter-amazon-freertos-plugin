package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import com.pycampers.plugin_scaffold.PluginScaffoldPlugin
import com.pycampers.plugin_scaffold.createPluginScaffold
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.logging.StreamHandler


/** FlutterAmazonFreertosPlugin */
public class FlutterAmazonFreeRTOSPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "nl.qwic.plugins.flutter_amazon_freertos_plugin")
//    channel.setMethodCallHandler(FlutterAmazonFreeRTOSPlugin());
    val plugin = FreeRTOSBluetooth(flutterPluginBinding.applicationContext)


    /*
    * Methods in ios
    * methodMap: [
                "bluetoothState": plugin.bluetoothState,
                "startScanForDevices": plugin.startScanForDevices,
                "stopScanForDevices": plugin.stopScanForDevices,
                "rescanForDevices": plugin.rescanForDevices,
                "connectToDevice": plugin.connectToDevice,
                "disconnectFromDevice": plugin.disconnectFromDevice,
                "discoverServices": plugin.discoverServices,
                "listServices": plugin.listServices,
                "readCharacteristic": plugin.readCharacteristic,
                "readDescriptor": plugin.readDescriptor,
                "writeDescriptor": plugin.writeDescriptor,
                "writeCharacteristic": plugin.writeCharacteristic,
                "setNotification": plugin.setNotification,
                "getMtu": plugin.getMtu,
                "setMtu": plugin.setMtu
            ]
            *
    * */
    createPluginScaffold(
            flutterPluginBinding.binaryMessenger,
            "nl.qwic.plugins.flutter_amazon_freertos_plugin",
            plugin
    )
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
//      val channel = MethodChannel(registrar.messenger(), "nl.qwic.plugins.flutter_amazon_freertos_plugin")
//      channel.setMethodCallHandler(FlutterAmazonFreeRTOSPlugin())
      val plugin = FreeRTOSBluetooth(registrar.context());
      val channel = createPluginScaffold(
              registrar.messenger(),
              "nl.qwic.plugins.flutter_amazon_freertos_plugin",
              plugin
      )


    }
  }

  class MyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      // TODO: This method is called when the BroadcastReceiver is receiving
      // an Intent broadcast.
      val action = intent.action
      if (action == BluetoothAdapter.ACTION_STATE_CHANGED) {
        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                BluetoothAdapter.ERROR)
        throw UnsupportedOperationException("Not yet implemented");
      }
      throw UnsupportedOperationException("Not yet implemented")
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        else -> {
          print("no impl");
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
