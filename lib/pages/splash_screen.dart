import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Kita tetap beri jeda minimal 2.5 detik agar animasi/splash terlihat
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // Skenario 1: Belum login sama sekali -> Lempar ke Auth
    if (user == null) {
      context.go('/auth');
      return;
    }

    try {
      // Skenario 2: Sudah login -> Kita intip dulu datanya di Firestore!
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Kalau dokumen nggak ada (misal bug/terhapus manual), suruh login ulang
        await FirebaseAuth.instance.signOut();
        if (mounted) context.go('/auth');
        return;
      }

      final userData = doc.data();
      final role = userData?['role'];
      final isSetupComplete = userData?['isSetupComplete'] ?? false;

      if (!mounted) return;

      // 🔹 LOGIKA KEBAL BOCOR KITA BERAKSI DARI SPLASH SCREEN!
      if (isSetupComplete == false) {
        context.go('/registration-wizard');
      } else if (role.toString().toUpperCase() == 'PMO') {
        context.go('/pmo-main-screen');
      } else {
        context.go('/main-screen');
      }
    } catch (e) {
      // Kalau lagi gak ada internet atau error Firestore, aman-nya suruh login ulang
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F7B2F),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Teks di tengah
            const Center(
              child: Text(
                'TBMATE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 66,
                  fontFamily: 'DarumadropOne',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Gambar di bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Image.asset(
                  'assets/images/pill.png',
                  width: 400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
