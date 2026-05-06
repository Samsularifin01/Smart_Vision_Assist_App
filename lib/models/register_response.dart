class RegisterResponse {
  final String status;
  final String message;
  final String? token;

  const RegisterResponse({
    required this.status,
    required this.message,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json["status"]?.toString() ?? "error",
      message: json["message"]?.toString() ?? "",
      token: json["token"]?.toString(),
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}
