import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final TTSService tts = TTSService();

  OTPScreen({super.key});

  // ============ VERIFY OTP CODE ============
  void verifyOTP(BuildContext context) {
    String otp = otpController.text.trim();

    // ============ VALIDASI OTP KOSONG ============
    if (otp.isEmpty) {
      tts.speak("Kode OTP harus diisi");
      return;
    }

    // ============ VALIDASI OTP HARUS 6 DIGIT ============
    if (otp.length < 6) {
      tts.speak("Kode OTP harus 6 digit");
      return;
    }

    // ============ LANGSUNG KE RESET PASSWORD (TANPA DATABASE) ============
    // NOTE: Fitur ini bypass validasi karena belum ada database
    tts.speak("Kode OTP valid, lanjut ke reset password");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    tts.speak("Halaman verifikasi kode OTP");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Verifikasi OTP"),
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

                    // 📬 ICON
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        size: 36,
                        color: AppColors.background,
                      ),
                    ),

                    SizedBox(height: 24),

                    // 📝 TITLE
                    Text(
                      "Verifikasi Kode OTP",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    // 📌 SUBTITLE
                    Text(
                      "Masukkan kode 6 digit yang telah dikirim ke email Anda",
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
              // 🔐 OTP LABEL
              Text(
                "Kode OTP",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              // 🔐 OTP FIELD - MAKSIMAL 6 DIGIT
              CustomTextField(
                label: "Masukkan 6 digit kode",
                controller: otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                maxLength: 6,
              ),

              SizedBox(height: 12),

              // 📌 INFO TEXT
              Text(
                "Kode ini hanya berlaku selama 1 menit setelah dikirim",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),

              SizedBox(height: 40),

              // ==================== VERIFY BUTTON ====================
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Verifikasi Kode",
                  onPressed: () => verifyOTP(context),
                ),
              ),

              SizedBox(height: 20),

              // ==================== RESEND CODE SECTION ====================
              Center(
                child: Column(
                  children: [
                    Text(
                      "Tidak menerima kode?",
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        tts.speak("Kode OTP telah dikirim ulang");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Kode OTP telah dikirim ulang ke email Anda"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        "Kirim Ulang Kode",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ==================== BACK BUTTON ====================
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Kembali",
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