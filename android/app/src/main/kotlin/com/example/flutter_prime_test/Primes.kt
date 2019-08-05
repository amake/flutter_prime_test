package com.example.flutter_prime_test

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

fun isPrime(n: Int): Boolean {
    if (n == 2) {
        return true;
    }
    for (i in (n - 1) downTo 2) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

fun primes() = generateSequence(2) { it + 1 }.filter { isPrime(it) }

const val reportingInterval = 250

class PrimeGenerator(val consumer: (Int) -> Unit) {

    var stopped = false
    var primes = primes()
    var count = 0

    suspend fun start() = withContext(Dispatchers.Default) {
        stopped = false
        for (prime in primes) {
            if (stopped) {
                break
            }
            count++
            if (count % reportingInterval == 0) {
                consumer(prime)
            }
        }
    }

    fun stop() {
        stopped = true
    }

    fun reset() {
        stop()
        primes = primes()
        count = 0
    }
}

class NativePrimes {

    external fun stringFromJNI(): String

    companion object {
        init {
            System.loadLibrary("native-lib")
        }
    }
}