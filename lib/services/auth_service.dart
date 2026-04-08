class AuthService {
  bool login(String email, String password) {
    // dummy login
    return email == "admin@gmail.com" && password == "1234";
  }
}