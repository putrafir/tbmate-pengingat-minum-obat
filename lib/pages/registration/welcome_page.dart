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
    return Container(
      color: kPrimaryGreen,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 🔹 SingleChildScrollView + IntrinsicHeight memastikan halaman tidak akan pernah error Overflow
            // walaupun dibuka di HP sekecil apapun.
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    // 🔹 Padding disamakan dengan halaman NameStep & RoleStep (32)
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔹 Spacer menggantikan SizedBox(height: 100) agar jarak atasnya fleksibel!
                        const Spacer(flex: 2),

                        Image.asset(
                          'assets/images/Group 20.png',
                          height: 180, // Sedikit disesuaikan agar proporsional
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),

                        Text(
                          "Hai $nickName! Senang\nkenalan denganmu.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Supaya aku bisa jadi teman sehat yang pas buatmu, boleh isi dulu ya beberapa data singkat",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        // 🔹 Spacer mendorong tombol ke paling bawah dengan dinamis
                        const Spacer(flex: 3),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBackgroundColor,
                              shape: RoundedRectangleBorder(
                                // 🔹 Radius disamakan dengan tombol di NameStep & RoleStep agar serasi
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Ayo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen,
                              ),
                            ),
                          ),
                        ),

                        // Jarak aman dari dasar layar (home indicator)
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
