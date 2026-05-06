import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class RegisterApiService {
  // Ubah nilai ini jika ingin memakai emulator Android (10.0.2.2).
  static const bool _useAndroidEmulator = false;

  // Ganti IP ini dengan IP laptop/PC Anda saat menggunakan HP fisik (ADB).
  static const String _deviceHost = "192.168.18.14:8000";

  static String get _baseUrl {
    if (Platform.isAndroid && _useAndroidEmulator) {
      return "http://10.0.2.2:8000";
    }
    return "http://$_deviceHost";
  }
  static const String _tokenKey = "auth_token";

  Future<RegisterResponse> register(RegisterRequest request) async {
    final Uri url = Uri.parse("$_baseUrl/register");

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      final RegisterResponse registerResponse =
          RegisterResponse.fromJson(jsonBody);

      if (registerResponse.isSuccess && registerResponse.token != null) {
        await _saveToken(registerResponse.token!);
      }

      return registerResponse;
    } catch (error) {
      return const RegisterResponse(
        status: "error",
        message: "Gagal terhubung ke server",
      );
    }
  }

  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}
