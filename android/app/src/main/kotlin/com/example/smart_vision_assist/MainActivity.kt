package com.example.smart_vision_assist

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val vibrationChannel = "smart_vision_assist/vibration"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            vibrationChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val milliseconds = call.argument<Int>("milliseconds") ?: 7000
                    result.success(vibrate(milliseconds.toLong()))
                }
                "stop" -> {
                    stopVibration()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun vibrate(milliseconds: Long): Boolean {
        val vibrator = getVibrator() ?: return false

        if (!vibrator.hasVibrator()) {
            return false
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = VibrationEffect.createOneShot(
                milliseconds,
                VibrationEffect.DEFAULT_AMPLITUDE
            )
            vibrator.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(milliseconds)
        }

        return true
    }

    private fun stopVibration() {
        getVibrator()?.cancel()
    }

    private fun getVibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager =
                getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vibratorManager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }
}
