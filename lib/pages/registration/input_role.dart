import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class RoleGroupSelectionScreen extends StatefulWidget {
  const RoleGroupSelectionScreen({super.key});

  @override
  State<RoleGroupSelectionScreen> createState() =>
      _RoleGroupSelectionScreenState();
}

class _RoleGroupSelectionScreenState extends State<RoleGroupSelectionScreen> {
  String? _selectedRoleGroup;
  bool _isSaving = false;

  // --- Simpan usia ke Firestore ---
  Future<void> _saveAgeGroupToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User belum login");
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'role': _selectedRoleGroup,
    }, SetOptions(merge: true));
  }

  // --- Aksi tombol lanjut ---
  Future<void> _handleNext() async {
    if (_selectedRoleGroup == null) return;

    setState(() => _isSaving = true);

    try {
      await _saveAgeGroupToFirestore();

      if (mounted) {
        context.go('/input-name');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      "Setiap orang punya kebutuhan berbeda. Kamu termasuk yang mana?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                      "Kelompok usia pasien membantu menentukan program pengobatan TB yang tepat menggunakan obat FDC (Kombinasi Dosis Tetap) — baik untuk PMO atau orang dewasa.",
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
                            "Pilih Grup Role",
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
                                      setState(
                                          () => _selectedRoleGroup = 'PMO');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _selectedRoleGroup == 'PMO'
                                            ? const Color(0xFF2F7D32)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "PMO",
                                        style: TextStyle(
                                          color: _selectedRoleGroup == 'PMO'
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
                                          () => _selectedRoleGroup = 'Pasien');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: _selectedRoleGroup == 'Pasien'
                                            ? const Color(0xFF2F7D32)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Pasien",
                                        style: TextStyle(
                                          color: _selectedRoleGroup == 'Pasien'
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
                        onPressed: _isSaving || _selectedRoleGroup == null
                            ? null
                            : _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF75CDE7),
                          disabledBackgroundColor: const Color(0xFFB6E7F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
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
