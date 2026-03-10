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

        // 🔹 Jika user belum pernah tersimpan di Firestore, tambahkan data default
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

        // 🔹 Ambil data user terbaru
        final userData = (await usersRef.doc(user.uid).get()).data();
        final role = userData?['role'];

        // 🔹 Tentukan navigasi berdasarkan role & kelengkapan data
        if (role == null) {
          context.go('/input-role');
        } else if (role.toString().toUpperCase() == 'PMO') {
          if (userData?['nickName'] == null || userData?['nickName'] == '') {
            context.go('/input-name');
          } else {
            context.go('/pmo-main-screen');
          }
        } else if (role.toString().toUpperCase() == 'PASIEN') {
          if (userData?['nickName'] == null || userData?['nickName'] == '') {
            context.go('/input-name');
          } else if (userData?['ageGroup'] == null) {
            context.go('/input-usia');
          } else if (userData?['weight'] == null) {
            context.go('/input-weight');
          } else {
            context.go('/main-screen');
          }
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

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    final userCredential = await authService.signInWithGoogle();
    setState(() => isLoading = false);

    if (userCredential != null) {
      final user = userCredential.user;
      final usersRef = FirebaseFirestore.instance.collection('users');

      // 🔹 Cek apakah user sudah ada di Firestore
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

      // 🔹 Ambil data user
      final userData = (await usersRef.doc(user.uid).get()).data();
      final role = userData?['role'];

      if (role == null) {
        context.go('/input-role');
      } else if (role.toString().toUpperCase() == 'PMO') {
        if (userData?['nickName'] == null || userData?['nickName'] == '') {
          context.go('/input-name');
        } else {
          context.go('/pmo-main-screen');
        }
      } else if (role.toString().toUpperCase() == 'PASIEN') {
        if (userData?['nickName'] == null || userData?['nickName'] == '') {
          context.go('/input-name');
        } else if (userData?['ageGroup'] == null) {
          context.go('/input-usia');
        } else if (userData?['weight'] == null) {
          context.go('/input-weight');
        } else {
          context.go('/main-screen');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil login dengan Google!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal login dengan Google")),
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
            title: 'Login',
            subtitle: 'Silakan masukkan email dan password Anda.',
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: kPrimaryGreen),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Kamu Pengguna Baru? ',
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
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      'Atau login dengan akun Google',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _loginWithGoogle,
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
                      label: const Text('Login with Google'),
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
