class LoginResponse {
  final String status;
  final String message;
  final String? token;

  const LoginResponse({
    required this.status,
    required this.message,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json["status"]?.toString() ?? "error",
      message: json["message"]?.toString() ?? "",
      token: json["token"]?.toString(),
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}
