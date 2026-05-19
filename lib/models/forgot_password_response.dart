class ForgotPasswordResponse {
  final String status;
  final String message;
  final String? token;
  final String? expired;

  const ForgotPasswordResponse({
    required this.status,
    required this.message,
    this.token,
    this.expired,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    
    return ForgotPasswordResponse(
      status: json["status"]?.toString() ?? "error",
      message: json["message"]?.toString() ?? "",
      token: json["token"]?.toString(),
      expired: json["expired"]?.toString(),
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}
