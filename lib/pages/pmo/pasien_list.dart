import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/akun_page.dart';
import 'package:tbmate_kmipn/pages/pmo/pmo_main_screen.dart';

class PasienList extends StatefulWidget {
  const PasienList({super.key});

  @override
  State<PasienList> createState() => _PasienListState();
}

class _PasienListState extends State<PasienList> {
  String? currentDoctorId;

  @override
  void initState() {
    super.initState();
    _getCurrentDoctorId();
  }

  Future<void> _getCurrentDoctorId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          currentDoctorId = user.uid;
        });

        // 🔹 Cek apakah user adalah PMO
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'];
          if (role == 'PMO') {
            await _ensureDoctorPatientsDoc(user.uid);
          }
        }
      } else {
        debugPrint("⚠️ Tidak ada user login");
      }
    } catch (e) {
      debugPrint("❌ Error ambil currentDoctorId: $e");
    }
  }

  /// 🔹 Fungsi untuk otomatis buat dokumen doctorPatients
  Future<void> _ensureDoctorPatientsDoc(String doctorId) async {
    final docRef = FirebaseFirestore.instance.collection('PMO').doc(doctorId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'patients': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Dokumen doctorPatients/$doctorId berhasil dibuat otomatis");
    } else {
      debugPrint("ℹ️ Dokumen doctorPatients/$doctorId sudah ada");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentDoctorId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FFF4),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF4),
      body: StreamBuilder<DocumentSnapshot>(
        // 🔹 Ambil daftar pasien untuk PMO login
        stream: FirebaseFirestore.instance
            .collection('PMO')
            .doc(currentDoctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _emptyState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> patientIds =
              data['patients'] != null ? List.from(data['patients']) : [];

          if (patientIds.isEmpty) {
            return _emptyState();
          }

          // 🔹 Query semua pasien berdasarkan ID pasien yang terdaftar
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: patientIds)
                .snapshots(),
            builder: (context, patientSnapshot) {
              if (patientSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!patientSnapshot.hasData ||
                  patientSnapshot.data!.docs.isEmpty) {
                return _emptyState();
              }

              final patients = patientSnapshot.data!.docs;

              return Column(children: [
                _buildHeader(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final data = patient.data() as Map<String, dynamic>;
                      final fullName = data['fullName'] ?? 'Tanpa Nama';
                      final nickName = data['nickName'] ?? '';
                      final email = data['email'] ?? '';
                      final photoUrl = data['photoUrl'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F5),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              'assets/icons/akun.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          title: Text(
                            fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            nickName.isNotEmpty ? '$nickName • $email' : email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PmoMainScreen(
                                  initialIndex: 1,
                                  customPage: AkunPage(
                                    fullName: fullName,
                                    uniqueId: data['uniqueId'] ?? '',
                                    role: data['role'] ?? '',
                                    patientUid: patient.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ]);
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70, right: 8),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddPatientDialog(context),
          backgroundColor: const Color(0xFF81D4FA),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Tambah Pasien",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  /// 🔹 Header UI
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Daftar Pasien",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Empty state widget
  Widget _emptyState() {
    return Column(
      children: [
        _buildHeader(),
        const Expanded(
          child: Center(
            child: Text(
              "Belum ada pasien disinkronkan",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 Dialog Modern Tambah Pasien
  void _showAddPatientDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tambah Pasien",
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, _, child) {
        String uniqueId = '';
        bool isExisting = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(animation.value),
              child: Opacity(
                opacity: animation.value,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔹 Close Button
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ),
                          ),

                          /// 🔹 Icon
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 34,
                              color: Color(0xFF2E7D32),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 🔹 Title
                          const Text(
                            "Tambah Pasien",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Apakah pasien sudah terdaftar di sistem?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// 🔹 Segmented Button
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExisting = true;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isExisting
                                          ? const Color(0xFF2E7D32)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sudah Terdaftar",
                                        style: TextStyle(
                                          color: isExisting
                                              ? Colors.white
                                              : const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/tambah-pasien-baru');
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Pasien Baru",
                                        style: TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// 🔹 Input
                          if (isExisting) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Masukkan ID Pasien",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextField(
                              onChanged: (val) => uniqueId = val.trim(),
                              decoration: InputDecoration(
                                hintText: "Ketik ID pasien",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2E7D32),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            /// 🔹 Info Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8F4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Pastikan ID pasien benar agar data dapat ditemukan.",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          /// 🔹 Simpan Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (uniqueId.isEmpty) return;

                                final query = await FirebaseFirestore.instance
                                    .collection('users')
                                    .where('uniqueId', isEqualTo: uniqueId)
                                    .limit(1)
                                    .get();

                                if (query.docs.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "ID Pasien tidak ditemukan.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final patientDoc = query.docs.first;
                                final patientDocId = patientDoc.id;
                                final patientData = patientDoc.data();

                                final doctorDoc = FirebaseFirestore.instance
                                    .collection('PMO')
                                    .doc(currentDoctorId);

                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  final snapshot =
                                      await transaction.get(doctorDoc);

                                  if (!snapshot.exists) {
                                    transaction.set(doctorDoc, {
                                      'patients': [patientDocId],
                                    });
                                  } else {
                                    final data = snapshot.data() ?? {};
                                    final List<dynamic> patients =
                                        List.from(data['patients'] ?? []);

                                    if (!patients.contains(patientDocId)) {
                                      patients.add(patientDocId);

                                      transaction.update(doctorDoc, {
                                        'patients': patients,
                                      });
                                    }
                                  }
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Pasien ${patientData['fullName']} berhasil ditambahkan.",
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Simpan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// 🔹 Batal
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
