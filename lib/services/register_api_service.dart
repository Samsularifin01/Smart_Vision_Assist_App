import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import 'api_config.dart';

class RegisterApiService {
  static const String _tokenKey = "auth_token";

  Future<RegisterResponse> register(RegisterRequest request) async {
    final Uri url = Uri.parse("${ApiConfig.baseUrl}/register");

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
