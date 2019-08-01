import 'dart:isolate';

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
