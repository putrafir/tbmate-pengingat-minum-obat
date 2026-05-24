import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';

class RoleStep extends StatefulWidget {
  final Function(String) onNext;
  const RoleStep({super.key, required this.onNext});

  @override
  State<RoleStep> createState() => _RoleStepState();
}

class _RoleStepState extends State<RoleStep> {
  String? _selectedRoleGroup;

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
                      'assets/images/Group 2643.png',
                      height: 160,
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "Setiap orang punya peran berbeda. Kamu masuk yang mana?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              22, // Sedikit diperbesar agar lebih berwibawa
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
                  // 🔹 COPYWRITING DIPERBAIKI
                  const Text(
                    "Pilih 'Pasien' untuk memantau jadwal minum obatmu, atau pilih 'PMO' jika kamu adalah pendamping yang mengawasi pengobatan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kSubtitleColor,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- KOTAK PEMILIHAN ROLE ---
                  Container(
                    width: double
                        .infinity, // Mengganti width: 1200 yang rawan error
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FFF3),
                      border: Border.all(
                        color: const Color(
                            0xFFA6D9E8), // Warna biru muda khas desainmu
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pilih Peranmu",
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
                          height: 56, // Tinggi wadah luar diperbesar
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0), // Abu-abu lembut
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              // Tombol PMO
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedRoleGroup = 'PMO'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _selectedRoleGroup == 'PMO'
                                          ? const Color(
                                              0xFF2E7D32) // Konsisten dengan kPrimaryGreen
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _selectedRoleGroup == 'PMO'
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
                                      "PMO",
                                      style: TextStyle(
                                        color: _selectedRoleGroup == 'PMO'
                                            ? Colors.white
                                            : Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Tombol Pasien
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedRoleGroup = 'Pasien'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _selectedRoleGroup == 'Pasien'
                                          ? const Color(0xFF2E7D32)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _selectedRoleGroup == 'Pasien'
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
                                      "Pasien",
                                      style: TextStyle(
                                        color: _selectedRoleGroup == 'Pasien'
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
                      onPressed: _selectedRoleGroup == null
                          ? null
                          : () => widget.onNext(_selectedRoleGroup!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF75CDE7), // Biru khas desainmu
                        disabledBackgroundColor:
                            Colors.grey.shade300, // Warna disable lebih natural
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Lanjutkan",
                        style: TextStyle(
                          color: _selectedRoleGroup == null
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
