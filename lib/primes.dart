import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';

Stream<int> primes = Stream<int>.fromIterable(_genPrimes());

void generatePrimes(SendPort sendPort) {
  for (final prime in _genPrimes()) {
    sendPort.send(prime);
  }
}

Iterable<int> _genPrimes() sync* {
  for (int i = 2;; i++) {
    if (_isPrime(i)) {
      yield i;
    }
  }
}

bool _isPrime(int n) {
  if (n == 2) {
    return true;
  }
  for (int i = n - 1; i > 1; i--) {
    if (n % i == 0) {
      return false;
    }
  }
  return true;
}

const _platform = MethodChannel('example.com/primes');

StreamController platformPrimes() {
  StreamController controller;
  _platform.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'addPrime':
        controller.add(call.arguments);
        return true;
      default:
        throw PlatformException(code: 'Unsupported method');
    }
  });
  controller = StreamController(
    onListen: () => _platform.invokeMethod('start'),
    onCancel: () {
      _platform.invokeMethod('cancel');
      controller.close();
    },
    onPause: () => _platform.invokeMethod('pause'),
    onResume: () => _platform.invokeMethod('resume'),
  );
  return controller;
}
