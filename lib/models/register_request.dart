class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "gender": gender,
      "password": password,
    };
  }
}
