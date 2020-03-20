import UIKit
import AmazonFreeRTOS
import AWSMobileClient
import AWSIoT
import plugin_scaffold

class FreeRTOSBluetooth {
    let awsFreeRTOSManager = AmazonFreeRTOSManager.shared

    func isOn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(awsFreeRTOSManager.central?.state == .powerdOn)
    }
}
