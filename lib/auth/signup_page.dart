import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';
import 'package:tbmate_kmipn/services/auth_service.dart';
import 'package:tbmate_kmipn/widgets/custom_password_field.dart';
import 'package:tbmate_kmipn/widgets/custom_text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool agreeToTerms = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = AuthService();

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi tidak sama")),
      );
      return;
    }

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Kamu harus menyetujui syarat & ketentuan")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await authService.register(email, password);
      if (userCredential != null) {
        final user = userCredential.user;
        final usersRef = FirebaseFirestore.instance.collection('users');

        final uniqueId = 'USR-${DateTime.now().millisecondsSinceEpoch}';

        // 🔹 Simpan data user baru ke Firestore
        await usersRef.doc(user!.uid).set({
          'uniqueId': uniqueId,
          'email': user.email,
          'role': null,
          'nickName': null,
          'ageGroup': null,
          'weight': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun berhasil dibuat!")),
        );

        // 🔹 Arahkan ke halaman input role
        context.go('/input-role');
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email sudah terdaftar!")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AuthHeader(
            imagePath: 'assets/tibi/tibi-happy.png',
            title: 'Buat Akun',
            subtitle: 'Silakan masukkan email dan password untuk membuat akun.',
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F9F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    CustomPasswordField(
                      hintText: 'Password',
                      controller: passwordController,
                    ),
                    const SizedBox(height: 16),
                    CustomPasswordField(
                      hintText: 'Confirm Password',
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (v) {
                            setState(() {
                              agreeToTerms = v!;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Saya setuju dengan ',
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' serta '),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: !isLoading ? _register : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign Up"),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun? ',
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go('/login');
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      'Atau gunakan akun Google',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              final userCredential =
                                  await authService.signInWithGoogle();
                              setState(() => isLoading = false);
                              if (userCredential != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Berhasil sign up dengan Google!")),
                                );
                                context.go('/input-role');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: Image.asset(
                        'assets/icons/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text('Sign Up with Google'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
