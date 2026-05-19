import 'dart:io';

class ApiConfig {
  // Ubah ke true jika memakai emulator Android (10.0.2.2).
  static const bool useAndroidEmulator = false;

  // Ganti IP ini dengan IP laptop/PC Anda saat menggunakan HP fisik (ADB).
  static const String deviceHost = "192.168.0.31:8000";

  static String get baseUrl {
    if (Platform.isAndroid && useAndroidEmulator) {
      return "http://10.0.2.2:8000";
    }
    return "http://$deviceHost";
  }
}
