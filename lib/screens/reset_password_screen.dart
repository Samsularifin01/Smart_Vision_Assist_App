import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TTSService tts = TTSService();
  String passwordStrength = ""; // Track password strength

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.speak("Halaman reset password");
    });

    // ============ LISTENER UNTUK PASSWORD REAL-TIME ============
    newPasswordController.addListener(() {
      setState(() {
        passwordStrength = _getPasswordStrength(newPasswordController.text);
      });
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============ FUNGSI UNTUK MENGHITUNG PASSWORD STRENGTH ============
  String _getPasswordStrength(String password) {
    if (password.isEmpty) {
      return "";
    }

    // ✅ Cek ada huruf besar
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    
    // ✅ Cek ada angka
    bool hasNumber = password.contains(RegExp(r'[0-9]'));

    // ✅ Penentuan strength
    if (password.length < 6) {
      return "weak"; // Password lemah
    } else if (hasUpperCase && hasNumber) {
      return "strong"; // Password kuat
    } else {
      return "medium"; // Password sedang
    }
  }

  // ============ FUNGSI UNTUK MENDAPATKAN WARNA PASSWORD STRENGTH ============
  Color _getPasswordStrengthColor() {
    switch (passwordStrength) {
      case "weak":
        return Colors.red; // Danger
      case "strong":
        return Colors.green; // Success
      case "medium":
        return Colors.orange; // Warning
      default:
        return Colors.transparent;
    }
  }

  // ============ FUNGSI UNTUK MENDAPATKAN TEXT PASSWORD STRENGTH ============
  String _getPasswordStrengthText() {
    switch (passwordStrength) {
      case "weak":
        return "Password lemah";
      case "strong":
        return "Password kuat";
      case "medium":
        return "Password sedang";
      default:
        return "";
    }
  }

  // ============ HANDLE RESET PASSWORD ============
  void resetPassword(BuildContext context) {
    String newPass = newPasswordController.text.trim();
    String confirmPass = confirmPasswordController.text.trim();

    // ============ VALIDASI PASSWORD KOSONG ============
    if (newPass.isEmpty || confirmPass.isEmpty) {
      tts.speak("Semua field harus diisi");
      return;
    }

    // ============ VALIDASI PASSWORD PANJANG ============
    if (newPass.length < 6) {
      tts.speak("Password minimal 6 karakter");
      return;
    }

    // ============ VALIDASI PASSWORD SAMA ============
    if (newPass != confirmPass) {
      tts.speak("Password tidak sama");
      return;
    }

    tts.speak("Password berhasil diubah, silakan login kembali");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Reset Password"),
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

                    // 🔑 ICON
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 36,
                        color: AppColors.background,
                      ),
                    ),

                    SizedBox(height: 24),

                    // 📝 TITLE
                    Text(
                      "Buat Password Baru",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    // 📌 SUBTITLE
                    Text(
                      "Masukkan password baru untuk keamanan akun Anda",
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

              // ==================== PASSWORD SECTION ====================
              Text(
                "Password Baru",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              // 🔐 NEW PASSWORD FIELD
              CustomTextField(
                label: "Masukkan password baru",
                controller: newPasswordController,
                obscure: true,
              ),

              // ============ PASSWORD STRENGTH INDICATOR ============
              if (passwordStrength.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getPasswordStrengthText(),
                    style: TextStyle(
                      color: _getPasswordStrengthColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              SizedBox(height: 20),

              // 📌 PASSWORD REQUIREMENT INFO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Requirement Password:",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• Minimal 6 karakter",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      "• Mengandung huruf besar (A-Z)",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      "• Mengandung angka (0-9)",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ==================== CONFIRM PASSWORD SECTION ====================
              Text(
                "Konfirmasi Password",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              // 🔐 CONFIRM PASSWORD FIELD
              CustomTextField(
                label: "Ulangi password baru",
                controller: confirmPasswordController,
                obscure: true,
              ),

              SizedBox(height: 32),

              // ==================== SUBMIT BUTTON ====================
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Simpan Password Baru",
                  onPressed: () => resetPassword(context),
                ),
              ),

              SizedBox(height: 16),

              // ==================== BACK TO LOGIN ====================
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  ),
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