import 'package:flutter/material.dart';
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
  final TTSService tts = TTSService();
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.speak("Halaman daftar akun");
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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

    if (selectedGender == null) {
      tts.speak("Jenis kelamin wajib dipilih");
      return;
    }

    tts.speak("Pendaftaran berhasil");
    Navigator.pop(context);
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
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            CustomTextField(
              label: "Email",
              controller: emailController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: "Password",
              controller: passwordController,
              obscure: true,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: "Konfirmasi Password",
              controller: confirmPasswordController,
              obscure: true,
            ),

            const SizedBox(height: 20),

            Semantics(
              label: "Pilih jenis kelamin",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.text),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jenis Kelamin",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                    buildGenderOption("Laki-laki"),
                    const Divider(color: Colors.white24, height: 1),
                    buildGenderOption("Perempuan"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

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
