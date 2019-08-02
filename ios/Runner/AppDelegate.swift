import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {

    setupPlatform()
    setupNative()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    private func setupPlatform() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "example.com/platform", binaryMessenger: controller)

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
    }

    private func setupNative() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "example.com/native", binaryMessenger: controller)
        globalChannel = channel
        c_consume_prime = consumePrime(prime:)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "start":
                DispatchQueue.global(qos: .userInitiated).async {
                    c_gen_primes_stop = false
                    c_gen_primes()
                }
                result(true)
            case "cancel":
                c_gen_primes_stop = true
                result(true)
            default:
                result(FlutterError())
            }
        }
    }
}

fileprivate var globalChannel : FlutterMethodChannel?

fileprivate func consumePrime(prime: Int32) {
    globalChannel?.invokeMethod("addPrime", arguments: prime)
}
