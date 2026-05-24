import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tbmate_kmipn/pages/pasien/profile/editBB.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/editNohp.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/edit_settime.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/editnama.dart';

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
  bool _isSavingProfile = false;
  bool get isPMOView => widget.patientUid != null;

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
                      )),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        if (isPMOView)
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                        Text(
                          isPMOView ? "Data Pasien" : "akun",
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
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7DD3FC),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.person,
                                size: 34,
                                color: Colors.grey,
                              ),
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

                            // if (!isPMOView)
                            //   ElevatedButton.icon(
                            //     onPressed: () {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) =>
                            //               EditNamaPage(
                            //             patientUid:
                            //                 widget.patientUid,
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //     style:
                            //         ElevatedButton.styleFrom(
                            //       backgroundColor:
                            //           Colors.white,
                            //       foregroundColor:
                            //           Colors.blue,
                            //       elevation: 0,
                            //       shape:
                            //           RoundedRectangleBorder(
                            //         borderRadius:
                            //             BorderRadius.circular(
                            //                 18),
                            //       ),
                            //       padding:
                            //           const EdgeInsets.symmetric(
                            //         horizontal: 16,
                            //         vertical: 14,
                            //       ),
                            //     ),
                            //     icon: const Icon(
                            //       Icons.edit_outlined,
                            //     ),
                            //     label:
                            //         const Text("Edit Profil"),
                            //   ),
                            if (!isPMOView)
                              InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => EditNamaPage(
                                  //       patientUid: widget.patientUid,
                                  //     ),
                                  //   ),
                                  // );
                                  _showEditProfilePopup(
                                      currentName: patientName,
                                      currentPhone: phone ?? '');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
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
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              "UID",
                              widget.uniqueId,
                              showCopy: true,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              "No. Handphone",
                             phone ?? "Tidak ada telp"
                            ),
                            const Divider(),
                            _buildInfoRow(
                              "Berat Badan",
                              weight != null ? "$weight kg" : "Belum ada",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              "Ubah Kata Sandi",
                              "********",
                            ),
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
                        onTap: () {},
                      ),

                      const SizedBox(height: 16),

                      // ================= ALARM =================
                      _buildMenuCard(
                        icon: Icons.access_time_rounded,
                        title: "Set Time Alarm",
                        subtitle: "Atur pengingat minum obat",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditSetTime(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ================= LOGOUT =================
                      _buildMenuCard(
                        icon: Icons.logout_rounded,
                        title: isPMOView ? "Hapus Pasien" : "Log Out",
                        subtitle: isPMOView
                            ? "Hapus pasien dari daftar"
                            : "Keluar dari akun TBMate",
                        color: Colors.red,
                        onTap: () async {
                          if (isPMOView) {
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
                                  content: Text(
                                    "Pasien berhasil dihapus",
                                  ),
                                ),
                              );

                              context.pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Gagal: $e",
                                  ),
                                ),
                              );
                            }
                          } else {
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
                                SnackBar(
                                  content: Text(
                                    'Logout gagal: $e',
                                  ),
                                ),
                              );
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

  // ================= INFO ROW =================

  void _showEditProfilePopup({
    required String currentName,
    required String currentPhone,
  }) {
    _nameController.text = currentName;
    _phoneController.text = currentPhone;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
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
                  // ================= HEADER =================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Edit Profil",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Perbarui informasi profil Anda",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= NAMA =================

                  const Text(
                    "Nama Lengkap",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Masukkan nama",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.blue.shade100,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= TELP =================

                  const Text(
                    "No. Handphone",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Masukkan nomor handphone",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.blue.shade100,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Pastikan nomor aktif agar menerima notifikasi.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= BUTTON =================

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingProfile
                          ? null
                          : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSavingProfile
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                         : const Text(
                            "Simpan",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
  }

  Future<void> _saveProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final targetUid = widget.patientUid ?? currentUser.uid;

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Nama dan nomor HP wajib diisi"),
      ));
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      // UPDATE PROFILE
      await FirebaseFirestore.instance.collection('users').doc(targetUid).set({
        'fullName': newName,
        'phoneNumber': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Profil berhasil diperbaharui",
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "gagal Update Profile: $e",
      )));
    }
    if (mounted) {
      setState(() {
        _isSavingProfile = false;
      });
    }
  }

  Widget _buildInfoRow(
    String title,
    String value, {
    bool showCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (showCopy) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: value),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "UID berhasil disalin",
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU CARD =================
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 26,
                color: color,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
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
