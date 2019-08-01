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

let reportingInterval = 250

class PrimeGenerator {
    init(consumer: @escaping (Int) -> Void) {
        self.consumer = consumer
    }

    private let consumer: (Int) -> Void
    private var stopped = false
    private var primes = Primes()
    private var count = 0

    func start() {
        stopped = false
        DispatchQueue.global(qos: .userInitiated).async {
            for prime in self.primes {
                if (self.stopped) {
                    break
                }
                self.count += 1
                if (self.count % reportingInterval == 0) {
                    self.consumer(prime)
                }
            }
        }
    }

    func stop() {
        stopped = true
    }

    func reset() {
        stop()
        primes = Primes()
        count = 0
    }
}

fileprivate func isPrime(_ n: Int) -> Bool {
    if (n == 2) {
        return true
    }
    for i in (2..<n).reversed() {
        if (n % i == 0) {
            return false
        }
    }
    return true
}

struct Primes : Sequence {
    func makeIterator() -> PrimeIterator {
        return PrimeIterator()
    }
}

struct PrimeIterator : IteratorProtocol {
    var i = 2

    mutating func next() -> Int? {
        for n in i...Int.max {
            i += 1
            if (isPrime(n)) {
                return n
            }
        }
        return nil
    }
}
