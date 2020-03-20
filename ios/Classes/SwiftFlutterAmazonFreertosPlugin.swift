import Flutter
import UIKit

public class SwiftFlutterAmazonFreeRTOSPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_amazon_freertos_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAmazonFreertosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
