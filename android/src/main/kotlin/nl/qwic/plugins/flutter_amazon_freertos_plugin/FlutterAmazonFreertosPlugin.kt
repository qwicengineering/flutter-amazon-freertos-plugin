package nl.qwic.plugins.flutter_amazon_freertos_plugin

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import com.pycampers.plugin_scaffold.createPluginScaffold
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterAmazonFreeRTOSPlugin */

private fun pluginInitializer(context: Context, messenger: BinaryMessenger) {
  val plugin = FreeRTOSBluetooth(context)
  val channel = createPluginScaffold(
          messenger,
          "nl.qwic.plugins.flutter_amazon_freertos_plugin",
          plugin
  )
  val mReceiver: BroadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      val action = intent.action
      if (action == BluetoothAdapter.ACTION_STATE_CHANGED) {
        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                BluetoothAdapter.ERROR)
        channel.invokeMethod("bluetoothStateChangeCallback", dumpBluetoothState(state))
      }
    }
  }

  val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
  context.registerReceiver(mReceiver, filter)
}

public class FlutterAmazonFreeRTOSPlugin: FlutterPlugin, MethodCallHandler {

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginInitializer(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger);
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
      pluginInitializer(registrar.context(), registrar.messenger());
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
