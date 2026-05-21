import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';

class AgeStep extends StatefulWidget {
  final bool isFromPMO;
  final Function(String) onNext;

  const AgeStep({super.key, this.isFromPMO = false, required this.onNext});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  String? _selectedAgeGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER HIJAU ---
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/images/Group 2643.png',
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      widget.isFromPMO
                          ? "Pilih kelompok usia pasien"
                          : "Setiap usia punya kebutuhan berbeda. Kamu termasuk yang mana?",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- BODY PUTIH MELENGKUNG ---
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Kelompok usia pasien membantu menentukan program pengobatan TB yang tepat menggunakan obat FDC (Kombinasi Dosis Tetap) — baik untuk anak-anak atau orang dewasa.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSubtitleColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- PILIH USIA ---
                    Container(
                      width: 1200,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FFF3),
                        border: Border.all(
                            color: const Color(0xFFA6D9E8), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pilih Grup Usia",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7D1E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                // Anak-anak
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                          _selectedAgeGroup = 'Anak-anak');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _selectedAgeGroup == 'Anak-anak'
                                            ? const Color(0xFF2F7D32)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Anak-anak",
                                        style: TextStyle(
                                          color:
                                              _selectedAgeGroup == 'Anak-anak'
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Dewasa
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _selectedAgeGroup = 'Dewasa');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _selectedAgeGroup == 'Dewasa'
                                            ? const Color(0xFF2F7D32)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Dewasa",
                                        style: TextStyle(
                                          color: _selectedAgeGroup == 'Dewasa'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- Tombol Lanjut ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedAgeGroup == null
                            ? null
                            : () => widget.onNext(_selectedAgeGroup!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF75CDE7),
                          disabledBackgroundColor: const Color(0xFFB6E7F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Lanjut",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
