import 'package:flutter/material.dart';
import 'package:smart_vision_assist/screens/camera_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../services/tts_service.dart';
import '../services/auth_service.dart';
import '../models/login_request.dart';
import '../utils/colors.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TTSService tts = TTSService();
  final AuthService auth = AuthService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.speak("Silakan login");
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    if (isLoading) {
      return;
    }

    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty) {
      _showMessage("Email wajib diisi");
      return;
    }

    if (!email.contains("@")) {
      _showMessage("Email tidak valid");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Password wajib diisi");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await auth.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    if (!context.mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess && response.token != null) {
      _showMessage(
        response.message.isNotEmpty ? response.message : "Login berhasil",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
    } else {
      _showMessage(
        response.message.isNotEmpty
            ? response.message
            : "Login gagal, periksa email dan password",
      );
    }
  }

  void handleForgotPassword(BuildContext context) {
    tts.speak("Menu lupa password");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
    );
  }

  void handleSignUp(BuildContext context) {
    tts.speak("Menu pendaftaran akun");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  void _showMessage(String message) {
    tts.speak(message);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Object Detector Assist",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                label: "Password",
                controller: passwordController,
                obscure: true,
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: isLoading ? "Memproses..." : "Login",
                onPressed: () => handleLogin(context),
              ),

              const SizedBox(height: 15),

              Semantics(
                button: true,
                label: "Lupa password",
                child: TextButton(
                  onPressed: () => handleForgotPassword(context),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              Semantics(
                button: true,
                label: "Daftar akun baru",
                child: TextButton(
                  onPressed: () => handleSignUp(context),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
