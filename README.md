# flutter_prime_test

A test comparing Flutter performance across three layers:

1. Dart (common)
2. "Platform": Swift (iOS) and Kotlin (Android)
3. "Native": C (iOS) and C++ (Android)

(I assume that Objective-C is similar to C, and Java is similar to Kotlin in
performance, so they are not used.)

This app implements a naive search for prime numbers, reporting in the UI one
prime number for every 250 found, along with the elapsed time since the previous
one.

## Observations

- In a debug build, Swift is astoundingly slow
- In a debug build, C++ starts fast but slows down surprisingly quickly
- In a release build, everything is pretty much equally fast
