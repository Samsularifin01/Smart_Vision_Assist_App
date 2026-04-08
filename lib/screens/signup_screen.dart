import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TTSService tts = TTSService();

  SignUpScreen({super.key});

  void handleSignUp(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;
    String confirm = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      tts.speak("Email dan password wajib diisi");
      return;
    }

    if (password != confirm) {
      tts.speak("Password tidak sama");
      return;
    }

    tts.speak("Pendaftaran berhasil");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    tts.speak("Halaman daftar akun");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            CustomTextField(
              label: "Email",
              controller: emailController,
            ),

            SizedBox(height: 20),

            CustomTextField(
              label: "Password",
              controller: passwordController,
              obscure: true,
            ),

            SizedBox(height: 20),

            CustomTextField(
              label: "Konfirmasi Password",
              controller: confirmPasswordController,
              obscure: true,
            ),

            SizedBox(height: 30),

            CustomButton(
              text: "Daftar",
              onPressed: () => handleSignUp(context),
            ),
          ],
        ),
      ),
    );
  }
}