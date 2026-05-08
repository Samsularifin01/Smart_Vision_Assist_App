class ResetPasswordResponse {
  final String status;
  final String message;

  const ResetPasswordResponse({
    required this.status,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      status: json["status"]?.toString() ?? "error",
      message: json["message"]?.toString() ?? "",
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}
