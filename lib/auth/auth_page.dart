import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';
import 'package:tbmate_kmipn/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final authService = AuthService();
  bool isLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    final userCredential = await authService.signInWithGoogle();
    setState(() => isLoading = false);

    if (userCredential != null) {
      final user = userCredential.user;
      final usersRef = FirebaseFirestore.instance.collection('users');

      // Cek apakah user sudah ada di Firestore
      final doc = await usersRef.doc(user!.uid).get();

      if (!doc.exists) {
        final uniqueId = 'USR-${DateTime.now().millisecondsSinceEpoch}';

        // Jika user baru, simpan data dasar dulu
        await usersRef.doc(user.uid).set({
          'uniqueId': uniqueId, // <--- Tambahkan ini
          'email': user.email,
          'role': null,
          'nickName': user.displayName ?? '',
          'ageGroup': null,
          'weight': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Ambil data terbaru user
      final userData = (await usersRef.doc(user.uid).get()).data();
      final role = userData?['role'];
      // Tentukan halaman tujuan berdasarkan kelengkapan data
      // 🔹 Tentukan halaman tujuan berdasarkan role dan kelengkapan data
      if (role == null) {
        context.go('/input-role');
        return;
      } else if (role?.toString().toUpperCase() == 'PMO') {
        if (userData?['nickName'] == null || userData?['nickName'] == '') {
          context.go('/input-name');
          return;
        } else {
          context.go('/pmo-main-screen');
          return;
        }
      } else if (role?.toString().toUpperCase() == 'PASIEN') {
        if (userData?['nickName'] == null || userData?['nickName'] == '') {
          context.go('/input-name');
          return;
        } else if (userData?['ageGroup'] == null) {
          context.go('/input-usia');
          return;
        } else if (userData?['weight'] == null) {
          context.go('/input-weight');
          return;
        } else {
          context.go('/main-screen');
          return;
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
            title: 'SELAMAT DATANG',
            subtitle:
                'Silakan masuk jika sudah punya akun, atau daftar sekarang untuk mulai menggunakan layanan',
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        context.push('/signup');
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        side: BorderSide(color: kPrimaryGreen, width: 2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        context.push('/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const Spacer(),
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
                      label: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login with Google'),
                    ),
                    const Spacer(),
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
