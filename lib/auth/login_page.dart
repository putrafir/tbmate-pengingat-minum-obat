// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';
import 'package:tbmate_kmipn/services/auth_service.dart';
import 'package:tbmate_kmipn/widgets/custom_password_field.dart';
import 'package:tbmate_kmipn/widgets/custom_text_field.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userCredential = await authService.login(email, password);
      setState(() => isLoading = false);

      if (userCredential != null) {
        final user = userCredential.user;
        final usersRef = FirebaseFirestore.instance.collection('users');
        final doc = await usersRef.doc(user!.uid).get();

        // Jika user belum pernah tersimpan di Firestore, tambahkan data default
        if (!doc.exists) {
          final uniqueId = 'USR-${DateTime.now().millisecondsSinceEpoch}';
          await usersRef.doc(user.uid).set({
            'uniqueId': uniqueId,
            'email': user.email,
            'role': null,
            'nickName': null,
            'ageGroup': null,
            'weight': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Ambil data user terbaru
        final userData = (await usersRef.doc(user.uid).get()).data();
        final role = userData?['role'];

        // 🔹 LOGIKA NAVIGASI BARU YANG SUPER BERSIH
        if (role == null) {
          context.go('/registration-wizard');
        } else if (role.toString().toUpperCase() == 'PMO') {
          context.go('/pmo-main-screen');
        } else {
          context.go('/main-screen');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login berhasil!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email atau password salah!")),
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
      // Secara default, resizeToAvoidBottomInset adalah true di Flutter.
      // Ini membuat layar mengecil saat keyboard muncul, sehingga kotak putih akan otomatis terdorong naik!
      body: Stack(
        children: [
          // ==========================================
          // LAYER 1: MASKOT (FIXED DI ATAS)
          // ==========================================
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: const AuthHeader(
                  imagePath: 'assets/tibi/tibi-happy.png',
                  title: 'Login',
                  subtitle: 'Silakan masukkan email dan password Anda.',
                ),
              ),
            ),
          ),

          // ==========================================
          // LAYER 2: KOTAK PUTIH (FIXED DI BAWAH & SLIDING)
          // ==========================================
          Align(
            alignment: Alignment.bottomCenter,
            // SingleChildScrollView agar form tetap bisa digeser jika HP-nya sangat kecil
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F9F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  // Bayangan tipis agar terlihat melayang di atas background hijau
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  // 🔹 KUNCI UTAMA: Memaksa kotak putih hanya mengambil tinggi seukuran isi formnya!
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 24),

                    Text.rich(
                      TextSpan(
                        text: 'Kamu Pengguna Baru? ',
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go('/signup');
                              },
                          ),
                        ],
                      ),
                    ),

                    // Area aman bawah untuk HP modern (tanpa tombol navigasi fisik)
                    const SafeArea(
                      top: false,
                      child: SizedBox(height: 10),
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
