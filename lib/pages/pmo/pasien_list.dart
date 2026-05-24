import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tbmate_kmipn/pages/pmo/pmo_main_screen.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/akun_page.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/akunpagenew.dart';

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
                                  customPage: AkunPageRev(
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
  /// 🔹 Dialog Modern Tambah Pasien (Hanya via UID)
  void _showAddPatientDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tambah Pasien",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, _, child) {
        String uniqueId = '';
        bool isSaving = false; // State untuk efek loading

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Gunakan PopScope agar dialog tidak bisa ditutup saat sedang loading
            return PopScope(
              canPop: !isSaving,
              child: Transform.scale(
                scale: Curves.easeOutBack.transform(animation.value),
                child: Opacity(
                  opacity: animation.value,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
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
                                onTap: isSaving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      size: 18,
                                      color: isSaving
                                          ? Colors.grey.shade400
                                          : Colors.black87),
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
                                Icons.person_search_rounded,
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
                            const SizedBox(height: 8),

                            /// 🔹 Subtitle
                            const Text(
                              "Masukkan UID Pasien yang sudah terdaftar di aplikasi TBMate.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),

                            /// 🔹 Input UID
                            TextField(
                              enabled: !isSaving,
                              onChanged: (val) => uniqueId = val.trim(),
                              decoration: InputDecoration(
                                hintText: "Contoh: USR-12345...",
                                prefixIcon:
                                    const Icon(Icons.qr_code_scanner_rounded),
                                filled: true,
                                fillColor: isSaving
                                    ? Colors.grey.shade100
                                    : Colors.grey.shade50,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
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
                            const SizedBox(height: 16),

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
                                  const Icon(Icons.info_outline,
                                      color: Color(0xFF2E7D32), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "UID pasien dapat dilihat pada halaman menu akun pasien.",
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            /// 🔹 Simpan Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        if (uniqueId.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "UID Pasien tidak boleh kosong")));
                                          return;
                                        }

                                        setStateDialog(() => isSaving = true);

                                        try {
                                          // 1. Cari Pasien
                                          final query = await FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .where('uniqueId',
                                                  isEqualTo: uniqueId)
                                              .limit(1)
                                              .get();

                                          if (query.docs.isEmpty) {
                                            setStateDialog(
                                                () => isSaving = false);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Pasien dengan UID tersebut tidak ditemukan.")));
                                            return;
                                          }

                                          final patientDoc = query.docs.first;
                                          final patientDocId = patientDoc.id;
                                          final patientRole =
                                              patientDoc.data()['role'];
                                          final patientName =
                                              patientDoc.data()['fullName'] ??
                                                  'Pasien';

                                          // Validasi cegah masukin sesama PMO
                                          if (patientRole
                                                  .toString()
                                                  .toUpperCase() ==
                                              'PMO') {
                                            setStateDialog(
                                                () => isSaving = false);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Gagal: UID tersebut milik akun PMO.")));
                                            return;
                                          }

                                          // 2. Simpan ke daftar PMO (Pakai arrayUnion anti duplikat)
                                          final doctorDoc = FirebaseFirestore
                                              .instance
                                              .collection('PMO')
                                              .doc(currentDoctorId);

                                          await FirebaseFirestore.instance
                                              .runTransaction(
                                                  (transaction) async {
                                            final snapshot = await transaction
                                                .get(doctorDoc);
                                            if (!snapshot.exists) {
                                              transaction.set(doctorDoc, {
                                                'patients': [patientDocId]
                                              });
                                            } else {
                                              transaction.update(doctorDoc, {
                                                'patients':
                                                    FieldValue.arrayUnion(
                                                        [patientDocId])
                                              });
                                            }
                                          });

                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Pasien $patientName berhasil ditambahkan."),
                                            backgroundColor: Colors.green,
                                          ));

                                          Navigator.pop(
                                              context); // Tutup dialog jika sukses
                                        } catch (e) {
                                          setStateDialog(
                                              () => isSaving = false);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text("Error: $e")));
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  disabledBackgroundColor:
                                      const Color(0xFF2E7D32).withOpacity(0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : const Text("Hubungkan",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),

                            /// 🔹 Batal
                            TextButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text("Batal",
                                  style: TextStyle(
                                      color: isSaving
                                          ? Colors.grey
                                          : const Color(0xFF2E7D32),
                                      fontSize: 15)),
                            ),
                          ],
                        ),
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
