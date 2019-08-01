import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "example.com/primes",
                                              binaryMessenger: controller)

    let primegen = PrimeGenerator { prime in
        channel.invokeMethod("addPrime", arguments: prime)
    }

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch call.method {
        case "start":
            primegen.start()
            result(true)
        case "cancel":
            primegen.reset()
            result(true)
        case "pause":
            primegen.stop()
            result(true)
        case "resume":
            primegen.start()
            result(true)
        default:
            result(FlutterError())
        }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
