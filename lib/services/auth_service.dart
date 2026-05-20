import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'api_config.dart';

class AuthService {
  static const String _tokenKey = "auth_token";

  Future<LoginResponse> login(LoginRequest request) async {
    final Uri url = Uri.parse("${ApiConfig.baseUrl}/login");

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.body.isEmpty) {
        return LoginResponse(
          status: "error",
          message: "Respons server kosong (status ${response.statusCode})",
        );
      }

      Map<String, dynamic> jsonBody;
      try {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return LoginResponse(
          status: "error",
          message: "Respons server tidak valid (status ${response.statusCode})",
        );
      }

      final LoginResponse loginResponse = LoginResponse.fromJson(jsonBody);

      if (loginResponse.isSuccess && loginResponse.token != null) {
        await _saveToken(loginResponse.token!);
      }

      return loginResponse;
    } catch (error) {
      return const LoginResponse(
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
