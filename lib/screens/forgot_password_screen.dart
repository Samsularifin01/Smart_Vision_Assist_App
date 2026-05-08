import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../services/forgot_password_api_service.dart';
import '../models/forgot_password_request.dart';
import '../utils/colors.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TTSService tts = TTSService();
  final ForgotPasswordApiService forgotApi = ForgotPasswordApiService();

  ForgotPasswordScreen({super.key});

  // ============ HANDLE RESET PASSWORD ============
  Future<void> handleReset(BuildContext context) async {
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

    final response = await forgotApi.requestReset(
      ForgotPasswordRequest(email: email),
    );

    if (!context.mounted) {
      return;
    }

    if (response.isSuccess) {
      if (response.token == null || response.token!.isEmpty) {
        tts.speak("Token OTP belum diterima dari server");
        return;
      }
      if (response.expired == null) {
        tts.speak("Waktu kedaluwarsa OTP belum diterima dari server");
        return;
      }
      tts.speak(response.message.isNotEmpty
          ? response.message
          : "OTP berhasil dikirim");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(
            email: email,
            serverToken: response.token!,
            expiredAt: response.expired!,
          ),
        ),
      );
    } else {
      tts.speak(response.message.isNotEmpty
          ? response.message
          : "Email tidak ditemukan");
    }
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