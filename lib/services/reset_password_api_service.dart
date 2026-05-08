import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reset_password_request.dart';
import '../models/reset_password_response.dart';
import 'api_config.dart';

class ResetPasswordApiService {
  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    final Uri url = Uri.parse("${ApiConfig.baseUrl}/reset-password");

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.body.isEmpty) {
        return ResetPasswordResponse(
          status: "error",
          message:
              "Respons server kosong (status ${response.statusCode})",
        );
      }

      Map<String, dynamic> jsonBody;
      try {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return ResetPasswordResponse(
          status: "error",
          message:
              "Respons server tidak valid (status ${response.statusCode})",
        );
      }

      final ResetPasswordResponse parsed =
          ResetPasswordResponse.fromJson(jsonBody);

      if (response.statusCode >= 400 && parsed.message.isEmpty) {
        return ResetPasswordResponse(
          status: "error",
          message:
              "Gagal reset password (status ${response.statusCode})",
        );
      }

      return parsed;
    } catch (error) {
      return const ResetPasswordResponse(
        status: "error",
        message: "Gagal terhubung ke server",
      );
    }
  }
}
