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
      // SafeArea bawah dimatikan agar kotak putih menempel mulus ke dasar layar
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==========================================
            // LAYER ATAS: HEADER & ILUSTRASI (FLEKSIBEL)
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/Group 2643.png', // Pastikan ini gambar yang tepat untuk umur
                      height: 160,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        widget.isFromPMO
                            ? "Pilih kelompok usia pasien yang kamu awasi"
                            : "Setiap usia punya kebutuhan berbeda. Kamu termasuk yang mana?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ==========================================
            // LAYER BAWAH: KOTAK PUTIH (PADAT / HUG CONTENT)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(32, 36, 32, 24),
              child: Column(
                // mainAxisSize.min memastikan form putih ini tidak memanjang sia-sia
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Kelompok usia pasien membantu menentukan program pengobatan TB yang tepat menggunakan obat FDC (Kombinasi Dosis Tetap).",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kSubtitleColor,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- KOTAK PEMILIHAN USIA ---
                  Container(
                    width: double.infinity, // Solusi width: 1200
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FFF3),
                      border: Border.all(
                        color: const Color(0xFFA6D9E8),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pilih Grup Usia",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- TOGGLE SWITCH ELEGAN ---
                        Container(
                          width: double.infinity,
                          height: 56, // Tinggi wadah luar diperbaiki
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              // Tombol Anak-anak
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedAgeGroup = 'Anak-anak'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _selectedAgeGroup == 'Anak-anak'
                                          ? const Color(0xFF2E7D32)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow:
                                          _selectedAgeGroup == 'Anak-anak'
                                              ? [
                                                  const BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2))
                                                ]
                                              : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Anak-anak",
                                      style: TextStyle(
                                        color: _selectedAgeGroup == 'Anak-anak'
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Tombol Dewasa
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedAgeGroup = 'Dewasa'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _selectedAgeGroup == 'Dewasa'
                                          ? const Color(0xFF2E7D32)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _selectedAgeGroup == 'Dewasa'
                                          ? [
                                              const BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2))
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Dewasa",
                                      style: TextStyle(
                                        color: _selectedAgeGroup == 'Dewasa'
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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

                  const SizedBox(height: 32),

                  // --- Tombol Lanjut ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedAgeGroup == null
                          ? null
                          : () => widget.onNext(_selectedAgeGroup!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF75CDE7),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Lanjutkan",
                        style: TextStyle(
                          color: _selectedAgeGroup == null
                              ? Colors.grey.shade500
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Margin bawah untuk keamanan gestur layar HP kekinian
                  const SafeArea(
                    top: false,
                    child: SizedBox(height: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
