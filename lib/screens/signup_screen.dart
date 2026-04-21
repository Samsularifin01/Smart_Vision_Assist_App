import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/tts_service.dart';
import '../utils/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TTSService tts = TTSService();
  String? selectedGender;
  String passwordStrength = ""; // Track password strength

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.speak("Halaman daftar akun");
    });

    // ============ LISTENER UNTUK PASSWORD REAL-TIME ============
    passwordController.addListener(() {
      setState(() {
        passwordStrength = _getPasswordStrength(passwordController.text);
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleSignUp(BuildContext context) {
    String name = nameController.text;
    String phone = phoneController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirm = confirmPasswordController.text;

    // ============ VALIDASI NAMA ============
    if (name.isEmpty) {
      tts.speak("Nama lengkap wajib diisi");
      return;
    }

    // ============ VALIDASI TELEPON ============
    if (phone.isEmpty) {
      tts.speak("Nomer telepon wajib diisi");
      return;
    }

    if (phone.length < 10) {
      tts.speak("Nomer telepon minimal 10 angka");
      return;
    }

    // ============ VALIDASI EMAIL ============
    if (email.isEmpty) {
      tts.speak("Email wajib diisi");
      return;
    }

    if (!email.contains("@")) {
      tts.speak("Email harus mengandung simbol @");
      return;
    }

    // ============ VALIDASI PASSWORD ============
    if (password.isEmpty) {
      tts.speak("Password wajib diisi");
      return;
    }

    if (password != confirm) {
      tts.speak("Password tidak sama");
      return;
    }

    // ============ VALIDASI JENIS KELAMIN ============
    if (selectedGender == null) {
      tts.speak("Jenis kelamin wajib dipilih");
      return;
    }

    tts.speak("Pendaftaran berhasil");
    Navigator.pop(context);
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

  Widget buildGenderOption(String gender) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      value: gender,
      groupValue: selectedGender,
      activeColor: AppColors.primary,
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.text;
      }),
      title: Text(
        gender,
        style: TextStyle(color: AppColors.text),
      ),
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });

        if (value != null) {
          tts.speak("Jenis kelamin $value dipilih");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Buat Akun Baru"),
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 32,
                        color: AppColors.background,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Daftar Akun",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Isi data diri Anda untuk membuat akun",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // ==================== PERSONAL INFO SECTION ====================
              Text(
                "Data Pribadi",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              CustomTextField(
                label: "Nama Lengkap",
                controller: nameController,
              ),

              SizedBox(height: 16),

              CustomTextField(
                label: "Nomer Telepon",
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                maxLength: 13,
              ),

              SizedBox(height: 20),

              // ==================== GENDER SELECTION ====================
              Text(
                "Jenis Kelamin",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),

              Semantics(
                label: "Pilih jenis kelamin",
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.text, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildGenderOption("Laki-laki"),
                      const Divider(color: Colors.white24, height: 8),
                      buildGenderOption("Perempuan"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 28),

              // ==================== CREDENTIALS SECTION ====================
              Text(
                "Keamanan Akun",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              CustomTextField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16),

              CustomTextField(
                label: "Password",
                controller: passwordController,
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

              SizedBox(height: 16),

              CustomTextField(
                label: "Konfirmasi Password",
                controller: confirmPasswordController,
                obscure: true,
              ),

              SizedBox(height: 32),

              // ==================== SUBMIT BUTTON ====================
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Daftar Sekarang",
                  onPressed: () => handleSignUp(context),
                ),
              ),

              SizedBox(height: 16),

              // ==================== BACK TO LOGIN ====================
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
