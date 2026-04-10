import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../services/tts_service.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'camera_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TTSService tts = TTSService();
  final AuthService auth = AuthService();

  LoginScreen({super.key});

  // 🔐 LOGIN
  void handleLogin(BuildContext context) {
    bool success = auth.login(
      emailController.text,
      passwordController.text,
    );

    if (success) {
      tts.speak("Login berhasil");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      tts.speak("Login gagal, periksa email dan password");
    }
  }

  // 🔑 FORGOT PASSWORD
  void handleForgotPassword(BuildContext context) {
    tts.speak("Menu lupa password");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
    );
  }

  // 🆕 SIGN UP
  void handleSignUp(BuildContext context) {
    tts.speak("Menu pendaftaran akun");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    tts.speak("Silakan login");

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔷 TITLE
            Text(
              "Object Detector Assist",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 40),

            // 📧 EMAIL
            CustomTextField(
              label: "Email",
              controller: emailController,
            ),

            SizedBox(height: 20),

            // 🔒 PASSWORD
            CustomTextField(
              label: "Password",
              controller: passwordController,
              obscure: true,
            ),

            SizedBox(height: 30),

            // 🔘 LOGIN BUTTON
            CustomButton(
              text: "Buka Kamera",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CameraScreen()),
                );
              },
            ),

            SizedBox(height: 15),

            // 🔹 FORGOT PASSWORD
            Semantics(
              button: true,
              label: "Lupa password",
              child: TextButton(
                onPressed: () => handleForgotPassword(context),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),

            // 🔹 SIGN UP
            Semantics(
              button: true,
              label: "Daftar akun baru",
              child: TextButton(
                onPressed: () => handleSignUp(context),
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
