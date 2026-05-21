import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';

class WelcomeStep extends StatelessWidget {
  final String nickName;
  final VoidCallback onNext; // 🔹 Callback ke Wizard

  const WelcomeStep({
    super.key,
    required this.nickName,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Container karena Scaffold sudah di-handle oleh RegistrationWizard
    return Container(
      color: kPrimaryGreen,
      child: SafeArea(
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
                    // 🔹 PANGGIL CALLBACK DI SINI (Gantikan context.go)
                    onPressed: onNext,
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
