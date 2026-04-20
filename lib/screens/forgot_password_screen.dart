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

  // ============ HANDLE RESET PASSWORD ============
  void handleReset(BuildContext context) {
    String email = emailController.text.trim();

    // ============ VALIDASI EMAIL KOSONG ============
    if (email.isEmpty) {
      tts.speak("Email harus diisi");
      return;
    }

    // ============ VALIDASI EMAIL WAJIB "@" ============
    if (!email.contains("@")) {
      tts.speak("Email harus mengandung simbol @");
      return;
    }

    tts.speak("OTP telah dikirim ke email Anda");
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
        title: const Text("Lupa Password"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== HEADER SECTION ====================
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),

                    // 🔐 ICON
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 36,
                        color: AppColors.background,
                      ),
                    ),

                    SizedBox(height: 24),

                    // 📝 TITLE
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    // 📌 SUBTITLE
                    Text(
                      "Masukkan email Anda untuk menerima kode OTP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),

              // ==================== FORM SECTION ====================
              // 📧 EMAIL LABEL
              Text(
                "Email Address",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              // 📧 EMAIL FIELD
              CustomTextField(
                label: "Masukkan email Anda",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 12),

              // 📌 INFO TEXT
              Text(
                "Kami akan mengirimkan kode OTP ke email ini untuk verifikasi",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),

              SizedBox(height: 40),

              // ==================== SUBMIT BUTTON ====================
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Kirim Kode OTP",
                  onPressed: () => handleReset(context),
                ),
              ),

              SizedBox(height: 20),

              // ==================== BACK BUTTON ====================
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Kembali ke Login",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}