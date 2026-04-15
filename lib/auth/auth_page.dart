// import 'package:awesome_notifications/awesome_notifications.dart';
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

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  final authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Daftarkan satpam
    WidgetsBinding.instance.addObserver(this);

    // 2. Suruh UI gambar halamannya dulu, baru panggil si pembuat pop-up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mintaIzinNotifikasi();
    });
  }

  @override
  void dispose() {
    // Wajib copot biar nggak bocor memori
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kalau aplikasi baru aja balik ke layar (habis milih akun Google atau dari Settings)
    if (state == AppLifecycleState.resumed) {
      // Kasih napas 300 milidetik buat layar HP siap, lalu refresh!
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _mintaIzinNotifikasi() async {
    // Biarkan UI AuthPage selesai ke-render selama 1 detik
    await Future.delayed(const Duration(seconds: 1));

    // // Baru minta izin!
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await authService.signInWithGoogle();

      // Cek apakah widget masih aktif setelah proses async selesai
      if (!mounted) return;
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
            'uniqueId': uniqueId,
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

        if (!mounted) return; // Wajib sebelum panggil context lagi

        // TAMPILKAN SNACKBAR SEBELUM NAVIGASI (karena ada return di bawah)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil login dengan Google!")),
        );

        // Tentukan halaman tujuan berdasarkan role dan kelengkapan data
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Gagal login: Proses dibatalkan atau user null")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Sistem: $e")),
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
