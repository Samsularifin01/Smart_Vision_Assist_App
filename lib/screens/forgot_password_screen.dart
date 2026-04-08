import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TTSService tts = TTSService();

  ForgotPasswordScreen({super.key});

 void handleReset(BuildContext context) {
  String email = emailController.text;

  if (email.isEmpty) {
    tts.speak("Email harus diisi");
    return;
  }
  tts.speak("OTP telah dikirim ke email ");
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => OTPScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    tts.speak("Halaman lupa password");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            Text(
              "Masukkan email untuk reset password",
              style: TextStyle(color: AppColors.text),
            ),

            SizedBox(height: 20),

            CustomTextField(
              label: "Email",
              controller: emailController,
            ),

            SizedBox(height: 30),

            CustomButton(
              text: "Kirim OTP",
              onPressed: () => handleReset(context),
            ),
          ],
        ),
      ),
    );
  }
}