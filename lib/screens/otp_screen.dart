import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../services/forgot_password_api_service.dart';
import '../models/forgot_password_request.dart';
import '../utils/colors.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String serverToken;
  final int expiredAt;

  const OTPScreen({
    super.key,
    required this.email,
    required this.serverToken,
    required this.expiredAt,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final TTSService tts = TTSService();
  final ForgotPasswordApiService forgotApi = ForgotPasswordApiService();
  late String currentToken;
  late int currentExpiredAt;

  @override
  void initState() {
    super.initState();
    currentToken = widget.serverToken;
    currentExpiredAt = widget.expiredAt;
  }

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

    final int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (nowSeconds > currentExpiredAt) {
      tts.speak("OTP sudah kedaluwarsa");
      return;
    }

    if (otp != currentToken) {
      tts.speak("OTP tidak sesuai");
      return;
    }

    tts.speak("Kode OTP valid, lanjut ke reset password");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: widget.email,
          token: currentToken,
        ),
      ),
    );
  }

  Future<void> resendOtp() async {
    final response = await forgotApi.requestReset(
      ForgotPasswordRequest(email: widget.email),
    );

    if (!mounted) {
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

      setState(() {
        currentToken = response.token!;
        currentExpiredAt = response.expired!;
      });

      tts.speak(response.message.isNotEmpty
          ? response.message
          : "OTP berhasil dikirim ulang");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode OTP telah dikirim ulang ke email Anda"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      tts.speak(response.message.isNotEmpty
          ? response.message
          : "Gagal mengirim ulang OTP");
    }
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
                "Kode ini hanya berlaku selama 2 menit setelah dikirim",
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
                        resendOtp();
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