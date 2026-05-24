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

    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password tidak boleh kosong")),
      );
      return;
    }

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
      // Register dengan email dan password
      final userCredential = await authService.register(email, password);

      if (userCredential != null) {
        final user = userCredential.user;
        final usersRef = FirebaseFirestore.instance.collection('users');

        // SIMPAN DATA KE FIRESTORE
        final doc = await usersRef.doc(user!.uid).get();
        if (!doc.exists) {
          final uniqueId = 'USR-${DateTime.now().millisecondsSinceEpoch}';
          await usersRef.doc(user.uid).set({
            'uniqueId': uniqueId,
            'email': user.email,
            'role': null,
            'nickName': user.displayName ?? '',
            'ageGroup': null,
            'weight': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (!mounted) return;
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil membuat akun!")),
        );
        // 🔹 DIARAHKAN KE WIZARD
        context.go('/registration-wizard');
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email sudah terdaftar atau ada kesalahan")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        final user = userCredential.user;
        final usersRef = FirebaseFirestore.instance.collection('users');

        // SIMPAN DATA KE FIRESTORE
        final doc = await usersRef.doc(user!.uid).get();
        if (!doc.exists) {
          final uniqueId = 'USR-${DateTime.now().millisecondsSinceEpoch}';
          await usersRef.doc(user.uid).set({
            'uniqueId': uniqueId,
            'email': user.email,
            'role': null,
            'nickName': user.displayName ?? '',
            'ageGroup': null,
            'weight': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (!mounted) return;
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil sign up dengan Google!")),
        );
        // 🔹 DIARAHKAN KE WIZARD
        context.go('/registration-wizard');
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Proses Google sign up dibatalkan")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi layar HP saat ini (akan dinamis saat keyboard muncul)
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: Stack(
        children: [
          // ==========================================
          // LAYER 1: MASKOT (SELALU AMAN DI ATAS)
          // ==========================================
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                // Sedikit dikurangi jarak atasnya agar proporsional
                padding: const EdgeInsets.only(top: 10.0),
                child: const AuthHeader(
                  imagePath: 'assets/tibi/tibi-happy.png',
                  title: 'Buat Akun',
                  subtitle: 'Silakan masukkan detail akun Anda.',
                ),
              ),
            ),
          ),

          // ==========================================
          // LAYER 2: KOTAK PUTIH (DIBATASI MAKS 75% LAYAR)
          // ==========================================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                // 🔹 KUNCI SAKTI: Kotak putih ini tidak akan pernah lebih tinggi dari 75% layar!
                maxHeight: screenHeight * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F9F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              // 🔹 Memastikan saat di-scroll, konten tidak tembus ke luar sudut melengkung
              clipBehavior: Clip.hardEdge,

              // 🔹 SCROLL BERADA DI DALAM KOTAK PUTIH
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // Jarak spasi dalam (padding) sedikit dikompres agar lebih padat
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    const SizedBox(height: 14), // Spasi diperkecil
                    CustomPasswordField(
                      hintText: 'Password',
                      controller: passwordController,
                    ),
                    const SizedBox(height: 14),
                    CustomPasswordField(
                      hintText: 'Confirm Password',
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 10),

                    // Baris Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          activeColor: kPrimaryGreen,
                          onChanged: (v) => setState(() => agreeToTerms = v!),
                        ),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Saya setuju dengan ',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              children: [
                                TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' serta '),
                                TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: !isLoading ? _register : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text("Sign Up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),

                    Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun? ',
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/login'),
                          ),
                        ],
                      ),
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
