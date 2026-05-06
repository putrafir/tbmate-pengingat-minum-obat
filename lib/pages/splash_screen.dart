import 'dart:async';
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
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      context.go('/auth'); // biar router yang decide
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F7B2F),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background color

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
