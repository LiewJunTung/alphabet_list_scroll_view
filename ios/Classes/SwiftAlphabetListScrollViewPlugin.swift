import Flutter
import UIKit

public class SwiftAlphabetListScrollViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "alphabet_list_scroll_view", binaryMessenger: registrar.messenger())
    let instance = SwiftAlphabetListScrollViewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
