import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/editBB.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/editNohp.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/edit_settime.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/editnama.dart';

class AkunPage extends StatefulWidget {
  final String fullName;
  final String uniqueId;
  final String role;
  final String? patientUid;
  const AkunPage({
    super.key,
    required this.fullName,
    required this.uniqueId,
    required this.role,
    this.patientUid,
  });

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  bool autoBackup = true;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header Hijau
            Container(
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
                        ),
                      ),
                      Text(
                        isPMOView ? "Data Pasien" : "Akun",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold
                        ),
                      )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Konten utama
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(
                      widget.patientUid ??
                          FirebaseAuth.instance.currentUser!.uid,
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

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Profile section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, color: Colors.grey),
                              ),
                              SizedBox(width: 10),
                              Text(
                                patientName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔹 Navigasi ke halaman Edit Nama
                        _buildListTile(
                          "UID",
                          trailingWidget: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: widget.uniqueId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "UID berhasil disalin ke clipboard")),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.uniqueId,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy,
                                    size: 18, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        _buildListTile(isPMOView ? "Nama" : "Edit Nama",
                            trailingText: isPMOView ? patientName : null,
                            showArrow: !isPMOView,
                            onTap: isPMOView
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditNamaPage(
                                                  patientUid: widget.patientUid,
                                                )));
                                  }),

                        // _buildListTile(
                        //   "No. Handphone",
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => EditPhoneNumberPage(
                        //           patientUid: widget.patientUid,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        _buildListTile(
                          "No. Handphone",
                          trailingText: isPMOView
                              ? (phone ?? 'Tidak Ada Telp')
                              : (phone == null
                                  ? "Tidak ada telp"
                                  : maskPhoneNumber(phone)),
                          showArrow: !isPMOView,
                          onTap: isPMOView
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPhoneNumberPage(
                                        patientUid: widget.patientUid,
                                      ),
                                    ),
                                  );
                                },
                        ),
                        if (widget.role != 'PMO')
                          _buildListTile("Berat Badan",
                              trailingText: isPMOView
                                  ? (widget != null
                                      ? "$weight kg"
                                      : "BElum Ada")
                                  : null,
                              showArrow: !isPMOView,
                              onTap: isPMOView
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditBBPage(
                                                    patientUid:
                                                        widget.patientUid,
                                                  )));
                                    }),

                        const SizedBox(height: 20),

                        // 🔹 Notifikasi section
                        _buildSectionTitle("Notifikasi"),
                        // _buildListTile("Nada Dering"),
                        _buildListTile(
                          "Set Time Alarm",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditSetTime(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Lainnya section
                        // _buildSectionTitle("Lainnya"),
                        // SwitchListTile(
                        //   contentPadding: EdgeInsets.zero,
                        //   title: const Text("Cadangkan"),
                        //   subtitle: const Text("Data dicadangkan secara otomatis"),
                        //   value: autoBackup,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       autoBackup = value;
                        //     });
                        //   },
                        //   secondary: const Icon(Icons.cloud_outlined),
                        // ),

                        const SizedBox(height: 25),

                        // 🔹 Tombol Logout
                        SizedBox(
                          width: double.infinity,
                          child: widget.patientUid != null
                              ? ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final pmoUid = FirebaseAuth
                                          .instance.currentUser!.uid;

                                      await FirebaseFirestore.instance
                                          .collection('doctorPatients')
                                          .doc(pmoUid)
                                          .update({
                                        'patients': FieldValue.arrayRemove(
                                            [widget.patientUid])
                                      });

                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Pasien berhasil dihapus dari daftar",
                                          ),
                                        ),
                                      );

                                      context.pop();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Gagal menghapus pasien: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Hapus Pasien"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final user =
                                          FirebaseAuth.instance.currentUser;

                                      if (user != null) {
                                        for (final provider
                                            in user.providerData) {
                                          if (provider.providerId ==
                                              'google.com') {
                                            await GoogleSignIn().signOut();
                                            break;
                                          }
                                        }
                                      }

                                      await FirebaseAuth.instance.signOut();

                                      if (!context.mounted) return;

                                      context.go('/auth');
                                    } catch (e) {
                                      debugPrint('logout error: $e');

                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Logout Gagal: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text("Log Out"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.lightBlueAccent.shade100,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  // ✅ Fungsi ListTile dengan dukungan onTap
  Widget _buildListTile(
    String title, {
    String? trailingText,
    Widget? trailingWidget,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: trailingWidget ??
          (trailingText != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingText,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (showArrow)
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                )
              : (showArrow
                  ? const Icon(Icons.chevron_right, color: Colors.grey)
                  : null)),
      onTap: onTap, // ✅ agar bisa diklik navigasi
    );
  }

  // 🔹 Widget untuk judul section
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            title == "Notifikasi"
                ? Icons.notifications_outlined
                : Icons.menu_book_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
