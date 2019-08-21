package com.example.flutter_prime_test

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext

class MainActivity : FlutterActivity(), CoroutineScope {

    override val coroutineContext: CoroutineContext = Dispatchers.Main + SupervisorJob()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setupPlatform()
        setupNative()

        GeneratedPluginRegistrant.registerWith(this)
    }

    private fun setupPlatform() {
        val channel = MethodChannel(flutterView, "example.com/platform")

        val primegen = PrimeGenerator { prime ->
            launch(Dispatchers.Main) {
                channel.invokeMethod("addPrime", prime)
            }
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    launch { primegen.start() }
                    result.success(true)
                }
                "cancel" -> {
                    primegen.reset()
                    result.success(true)
                }
                "pause" -> {
                    primegen.stop()
                    result.success(true)
                }
                "resume" -> {
                    launch { primegen.start() }
                    result.success(true)
                }
                else -> result.error("Method unsupported: ${call.method}", null, null)
            }
        }
    }

    private fun setupNative() {
        val channel = MethodChannel(flutterView, "example.com/native")

        val primegen = NativePrimes { prime ->
            launch(Dispatchers.Main) {
                channel.invokeMethod("addPrime", prime)
            }
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    launch { primegen.start() }
                    result.success(true)
                }
                "cancel" -> {
                    primegen.stop()
                    result.success(true)
                }
                else -> result.error("Method unsupported: ${call.method}", null, null)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineContext[Job]!!.cancel()
    }
}
