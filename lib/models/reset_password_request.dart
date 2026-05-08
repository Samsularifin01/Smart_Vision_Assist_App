class ResetPasswordRequest {
  final String email;
  final String token;
  final String password;

  const ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "token": token,
      "password": password,
    };
  }
}
