import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final TTSService tts = TTSService();

  OTPScreen({super.key});

  void verifyOTP(BuildContext context) {
    String otp = otpController.text;

    if (otp.isEmpty) {
      tts.speak("Kode OTP harus diisi");
      return;
    }

    // 🔥 simulasi OTP benar
    if (otp == "1234") {
      tts.speak("OTP benar");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
      );
    } else {
      tts.speak("OTP salah");
    }
  }

  @override
  Widget build(BuildContext context) {
    tts.speak("Masukkan kode OTP");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Verifikasi OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 30),

            Text(
              "Masukkan kode OTP",
              style: TextStyle(color: AppColors.text),
            ),

            SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "OTP",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),

            SizedBox(height: 30),

            CustomButton(
              text: "Verifikasi",
              onPressed: () => verifyOTP(context),
            ),
          ],
        ),
      ),
    );
  }
}