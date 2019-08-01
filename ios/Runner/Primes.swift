//
//  Primes.swift
//  Runner
//
//  Created by Aaron Madlon-Kay on 2019/08/02.
//  Copyright © 2019. All rights reserved.
//

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
