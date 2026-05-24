import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePatientAccountPage extends StatefulWidget {
  const CreatePatientAccountPage({super.key});

  @override
  State<CreatePatientAccountPage> createState() =>
      _CreatePatientAccountPageState();
}

class _CreatePatientAccountPageState extends State<CreatePatientAccountPage> {
  final uidController = TextEditingController();
  bool isLoading = false;

  Future<void> _addPatient() async {
    final uniqueId = uidController.text.trim();

    if (uniqueId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("UID Pasien wajib diisi")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      /// ================= PMO AKTIF =================
      final currentPMO = FirebaseAuth.instance.currentUser;
      if (currentPMO == null) throw "PMO tidak ditemukan, silakan login ulang.";
      final pmoUid = currentPMO.uid;

      /// ================= 1. CARI PASIEN VIA UID =================
      // Kita query collection users berdasarkan field 'uniqueId' (Contoh: USR-123456789)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Pasien dengan UID tersebut tidak ditemukan")),
        );
        return;
      }

      final patientDoc = querySnapshot.docs.first;
      final patientUid = patientDoc
          .id; // Ini adalah Document ID asli (Firebase Auth UID) pasien
      final patientName = patientDoc.data()['fullName'] ?? 'Pasien';
      final patientRole = patientDoc.data()['role'];

      // Validasi: Cegah menambahkan sesama PMO
      if (patientRole.toString().toUpperCase() == 'PMO') {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal: UID tersebut milik akun PMO")),
        );
        return;
      }

      /// ================= 2. HUBUNGKAN KE PMO =================
      // Konsisten dengan logika hapus pasien di AkunPageRev, kita gunakan koleksi 'PMO'
      final pmoRef = FirebaseFirestore.instance.collection('PMO').doc(pmoUid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(pmoRef);

        if (!snapshot.exists) {
          // Kalau dokumen PMO belum ada, buat baru
          transaction.set(pmoRef, {
            'patients': [patientUid],
          });
        } else {
          // arrayUnion otomatis mencegah ID yang sama dimasukkan 2 kali (anti duplikat)
          transaction.update(pmoRef, {
            'patients': FieldValue.arrayUnion([patientUid]),
          });
        }
      });

      if (!mounted) return;
      setState(() => isLoading = false);

      /// ================= 3. SUCCESS =================
      showDialog(
        context: context,
        barrierDismissible: false, // Wajib klik tombol OK
        builder: (_) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text("Berhasil",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
                "Pasien $patientName berhasil ditambahkan ke daftar pengawasanmu."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup Dialog
                  context.pop(); // Kembali ke halaman utama PMO
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32)),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: SafeArea(
        bottom: false, // Agar form putih mulus sampai bawah layar
        child: Column(
          children: [
            /// ================= HEADER =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      /// BACK BUTTON
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// ICON
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .person_search_rounded, // 🔹 Icon diganti jadi pencarian
                          size: 60,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// TITLE
                      const Text(
                        "Tambah Pasien",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// SUBTITLE
                      const Text(
                        "Masukkan UID Pasien yang sudah terdaftar di aplikasi TBMate untuk mulai melakukan pengawasan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// ================= FORM =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F8F2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hug content
                children: [
                  /// UID PASIEN
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: TextField(
                      controller: uidController,
                      decoration: const InputDecoration(
                        hintText: "Contoh: USR-1715000000000",
                        prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _addPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EC1E4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Hubungkan Pasien",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  // Area aman bawah untuk HP modern
                  const SafeArea(top: false, child: SizedBox(height: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
