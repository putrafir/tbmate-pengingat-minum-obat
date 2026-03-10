import 'package:flutter/material.dart';
// Asumsi ini adalah file yang berisi kPrimaryGreen dan kBackgroundColor
import 'package:tbmate_kmipn/color.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  final String nickName;

  const WelcomePage({super.key, required this.nickName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/Group 20.png',
                
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),
              Text(
                "Hai $nickName! Senang\nkenalan denganmu.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kBackgroundColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Supaya aku bisa jadi teman sehat yang pas buatmu, boleh isi dulu ya beberapa data singkat",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kBackgroundColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/input-usia');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "Ayo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                      ),
                    ),
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
