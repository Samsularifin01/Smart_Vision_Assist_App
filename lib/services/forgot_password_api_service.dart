import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forgot_password_request.dart';
import '../models/forgot_password_response.dart';
import 'api_config.dart';

class ForgotPasswordApiService {
  Future<ForgotPasswordResponse> requestReset(
    ForgotPasswordRequest request,
  ) async {
    final Uri url = Uri.parse("${ApiConfig.baseUrl}/forgot-password");

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      return ForgotPasswordResponse.fromJson(jsonBody);
    } catch (error) {
      return const ForgotPasswordResponse(
        status: "error",
        message: "Gagal terhubung ke server",
      );
    }
  }
}
