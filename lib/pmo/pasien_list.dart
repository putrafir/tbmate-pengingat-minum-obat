import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final docRef = FirebaseFirestore.instance.collection('doctorPatients').doc(doctorId);
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
      body: FutureBuilder<DocumentSnapshot>(
        // 🔹 Ambil daftar pasien untuk PMO login
        future: FirebaseFirestore.instance
            .collection('doctorPatients')
            .doc(currentDoctorId)
            .get(),
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

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green.shade200,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : const AssetImage(
                                      'assets/images/default_profile.png')
                                  as ImageProvider,
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
                          context.push('/patient-detail', extra: patient.id);
                        },
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

  /// 🔹 Dialog untuk menambah pasien manual lewat uniqueId
  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String uniqueId = '';
        bool isExisting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tambah Pasien"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Apakah pasien sudah terdaftar di aplikasi?"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => isExisting = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExisting
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade300,
                          ),
                          child: const Text("Sudah Terdaftar"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/tambah-pasien-baru');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81D4FA),
                          ),
                          child: const Text("Belum Terdaftar"),
                        ),
                      ),
                    ],
                  ),
                  if (isExisting) ...[
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (val) => uniqueId = val.trim(),
                      decoration: const InputDecoration(
                        labelText: 'Masukkan ID Pasien (uniqueId)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                if (isExisting)
                  ElevatedButton(
                    onPressed: () async {
                      if (uniqueId.isEmpty) return;

                      // 🔍 Cari pasien berdasarkan uniqueId
                      final query = await FirebaseFirestore.instance
                          .collection('users')
                          .where('uniqueId', isEqualTo: uniqueId)
                          .limit(1)
                          .get();

                      if (query.docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("ID Pasien tidak ditemukan."),
                          ),
                        );
                        return;
                      }

                      final patientDoc = query.docs.first;
                      final patientDocId = patientDoc.id;
                      final patientData =
                          patientDoc.data() as Map<String, dynamic>;

                      // 🔹 Simpan ke daftar pasien milik PMO login (UID)
                      final doctorDoc = FirebaseFirestore.instance
                          .collection('doctorPatients')
                          .doc(currentDoctorId);

                      await FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        final snapshot = await transaction.get(doctorDoc);
                        if (!snapshot.exists) {
                          transaction.set(doctorDoc, {
                            'patients': [patientDocId],
                          });
                        } else {
                          final data =
                              snapshot.data() as Map<String, dynamic>? ?? {};
                          final List<dynamic> patients =
                              List.from(data['patients'] ?? []);
                          if (!patients.contains(patientDocId)) {
                            patients.add(patientDocId);
                            transaction.update(
                                doctorDoc, {'patients': patients});
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
                    ),
                    child: const Text("Simpan"),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
