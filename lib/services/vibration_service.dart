import 'package:flutter/services.dart';

class VibrationService {
  static const MethodChannel _channel =
      MethodChannel("smart_vision_assist/vibration");

  Future<void> vibrateFor(Duration duration) async {
    try {
      final bool? didVibrate = await _channel.invokeMethod<bool>(
        "vibrate",
        {"milliseconds": duration.inMilliseconds},
      );

      if (didVibrate == true) {
        return;
      }
    } catch (_) {
      // Fallback untuk perangkat/platform yang tidak mendukung channel native.
    }

    await HapticFeedback.vibrate();
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>("stop");
    } catch (_) {
      // Tidak perlu aksi tambahan jika platform tidak mendukung stop vibration.
    }
  }
}
