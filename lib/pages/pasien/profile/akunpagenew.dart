import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tbmate_kmipn/pages/pasien/profile/edit_settime.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/alarmpage.dart';

class AkunPageRev extends StatefulWidget {
  final String fullName;
  final String uniqueId;
  final String role;
  final String? patientUid;

  const AkunPageRev({
    super.key,
    required this.fullName,
    required this.uniqueId,
    required this.role,
    this.patientUid,
  });

  @override
  State<AkunPageRev> createState() => _AkunPageRevState();
}

class _AkunPageRevState extends State<AkunPageRev> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool get isPMOView => widget.patientUid != null;
  // 🔹 Cek apakah ini adalah PMO yang sedang melihat profilnya sendiri
  bool get isPersonalPMO => widget.role.toUpperCase() == 'PMO' && !isPMOView;

  String maskPhoneNumber(String phone) {
    if (phone.length <= 3) return phone;
    final visible = phone.substring(phone.length - 3);
    final hidden = '*' * (phone.length - 3);
    return '$hidden$visible';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBF4),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(
              widget.patientUid ?? FirebaseAuth.instance.currentUser!.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic>? userData;

          if (snapshot.hasData && snapshot.data!.exists) {
            userData = snapshot.data!.data() as Map<String, dynamic>;
          }

          final patientName = userData?['fullName'] ?? widget.fullName;
          final phone = userData?['phoneNumber'];
          final weight = userData?['weight'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        if (isPMOView)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                        Text(
                          isPMOView
                              ? "Data Pasien"
                              : "Akun Saya", // 🔹 Diperbaiki jadi Kapital
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ================= PROFILE CARD =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7DD3FC),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 34, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patientName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    userData?['email'] ?? 'tidak ada email',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            if (!isPMOView)
                              InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  _showEditProfilePopup(
                                    currentName: patientName,
                                    currentPhone: phone ?? '',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border:
                                        Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit_outlined,
                                          color: Colors.blue, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "Edit Profil",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= INFO CARD =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow("UID", widget.uniqueId,
                                showCopy: true),
                            const Divider(),
                            _buildInfoRow(
                                "No. Handphone", phone ?? "Belum diatur"),

                            // 🔹 Berat badan disembunyikan jika yang login adalah PMO
                            if (!isPersonalPMO) ...[
                              const Divider(),
                              _buildInfoRow("Berat Badan",
                                  weight != null ? "$weight kg" : "Belum ada"),
                            ],

                            const Divider(),
                            _buildInfoRow("Ubah Kata Sandi", "********"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= NOTIFIKASI =================
                      _buildMenuCard(
                        icon: Icons.notifications_none_rounded,
                        title: "Notifikasi",
                        subtitle: "Kelola preferensi notifikasi",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Alarmpage()));
                        },
                      ),
                      const SizedBox(height: 16),

                      // ================= ALARM (Disembunyikan untuk PMO Pribadi) =================
                      if (!isPersonalPMO) ...[
                        _buildMenuCard(
                          icon: Icons.access_time_rounded,
                          title: "Set Time Alarm",
                          subtitle: "Atur pengingat minum obat",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditSetTime()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ================= LOGOUT / HAPUS =================
                      _buildMenuCard(
                        icon: Icons.logout_rounded,
                        title: isPMOView ? "Hapus Pasien" : "Log Out",
                        subtitle: isPMOView
                            ? "Hapus pasien dari daftar pengawasan"
                            : "Keluar dari akun TBMate",
                        color: Colors.red,
                        onTap: () async {
                          if (isPMOView) {
                            // ... Logika Hapus Pasien ...
                            try {
                              final pmoUid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              await FirebaseFirestore.instance
                                  .collection('PMO')
                                  .doc(pmoUid)
                                  .update({
                                'patients':
                                    FieldValue.arrayRemove([widget.patientUid])
                              });
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Pasien berhasil dihapus")));
                              context.pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Gagal: $e")));
                            }
                          } else {
                            // ... Logika Logout ...
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                for (final provider in user.providerData) {
                                  if (provider.providerId == 'google.com') {
                                    await GoogleSignIn().signOut();
                                    break;
                                  }
                                }
                              }
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              context.go('/auth');
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Logout gagal: $e')));
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= POPUP EDIT PROFIL (STATEFUL BUILDER) =================
  void _showEditProfilePopup(
      {required String currentName, required String currentPhone}) {
    _nameController.text = currentName;
    _phoneController.text = currentPhone;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool isSaving = false; // 🔹 Local state khusus untuk popup ini

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              // 🔹 Dibungkus insetPadding agar tidak error saat keyboard muncul
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER POPUP ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Edit Profil",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text("Perbarui informasi profil Anda",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // --- FORM NAMA ---
                      const Text("Nama Lengkap",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Masukkan nama",
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade100)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- FORM TELP ---
                      const Text("No. Handphone",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Masukkan nomor handphone",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade100)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                          "Pastikan nomor aktif agar menerima notifikasi.",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 32),

                      // --- TOMBOL BATAL & SIMPAN ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                              child: const Text("Batal",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final newName =
                                          _nameController.text.trim();
                                      final newPhone =
                                          _phoneController.text.trim();

                                      if (newName.isEmpty || newPhone.isEmpty) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Nama dan nomor HP wajib diisi")));
                                        return;
                                      }

                                      // 🔹 Set loading aktif (khusus untuk popup ini)
                                      setStateDialog(() => isSaving = true);

                                      final success = await _saveProfileToDB(
                                          newName, newPhone);

                                      if (success && dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Profil berhasil diperbarui",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                backgroundColor: Colors.green));
                                      } else {
                                        // Matikan loading jika gagal
                                        setStateDialog(() => isSaving = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5))
                                  : const Text("Simpan",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Fungsi Save dipisah dan mengembalikan boolean (true = sukses)
  Future<bool> _saveProfileToDB(String newName, String newPhone) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final targetUid = widget.patientUid ?? currentUser.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(targetUid).set({
        'fullName': newName,
        'phoneNumber': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal Update Profile: $e")));
      }
      return false;
    }
  }

  // ================= KOMPONEN LAINNYA =================
  Widget _buildInfoRow(String title, String value, {bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
                if (showCopy) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("UID berhasil disalin")));
                    },
                    child: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
