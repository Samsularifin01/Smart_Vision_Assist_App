import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TTSService tts = TTSService();

  ResetPasswordScreen({super.key});

  void resetPassword(BuildContext context) {
    String newPass = newPasswordController.text;
    String confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      tts.speak("Semua field harus diisi");
      return;
    }

    if (newPass != confirmPass) {
      tts.speak("Password tidak sama");
      return;
    }

    tts.speak("Password berhasil diubah");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    tts.speak("Halaman reset password");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            CustomTextField(
              label: "Password Baru",
              controller: newPasswordController,
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
              text: "Simpan Password",
              onPressed: () => resetPassword(context),
            ),
          ],
        ),
      ),
    );
  }
}