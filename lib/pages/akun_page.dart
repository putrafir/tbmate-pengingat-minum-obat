import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tbmate_kmipn/pages/editNohp.dart';
import 'package:tbmate_kmipn/pages/editnama.dart';
import 'package:tbmate_kmipn/pages/edit_settime.dart';
import 'package:go_router/go_router.dart';

class AkunPage extends StatefulWidget {
  final String fullName;
  final String uniqueId;
  final String role;
  const AkunPage(
      {super.key,
      required this.fullName,
      required this.uniqueId,
      required this.role});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  bool autoBackup = true;

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
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Akun",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Konten utama
            Container(
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
                          widget.fullName,
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
                        Clipboard.setData(ClipboardData(text: widget.uniqueId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("UID berhasil disalin ke clipboard")),
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
                          const Icon(Icons.copy, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  _buildListTile(
                    "Edit Nama",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditNamaPage(),
                        ),
                      );
                    },
                  ),

                  _buildListTile(
                    "No. Handphone",
                    trailingText: "*****46",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPhoneNumberPage(),
                        ),
                      );
                    },
                  ),

                  if (widget.role != 'PMO') _buildListTile("Berat Badan"),

                  const SizedBox(height: 20),

                  // 🔹 Notifikasi section
                  _buildSectionTitle("Notifikasi"),
                  _buildListTile("Nada Dering"),
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
                  _buildSectionTitle("Lainnya"),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Cadangkan"),
                    subtitle: const Text("Data dicadangkan secara otomatis"),
                    value: autoBackup,
                    onChanged: (value) {
                      setState(() {
                        autoBackup = value;
                      });
                    },
                    secondary: const Icon(Icons.cloud_outlined),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // onPressed: () async {
                      //   try {
                      //     await FirebaseAuth.instance.signOut();
                      //     await GoogleSignIn().signOut();

                      //     if (!context.mounted) return;
                      //     context.go('/auth');
                      //   } catch (e) {
                      //     debugPrint('Logout error: $e');
                      //     if (!context.mounted) return;

                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text('Loug gagal: $e')),
                      //     );
                      //   }
                      // },
                      onPressed: () async {
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
                          debugPrint('logout error: $e');

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout Gagal: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent.shade100,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
    );
  }

  // ✅ Fungsi ListTile dengan dukungan onTap
  Widget _buildListTile(String title,
      {String? trailingText, Widget? trailingWidget, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: trailingWidget ??
          (trailingText != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(trailingText,
                        style: const TextStyle(color: Colors.grey)),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                )
              : const Icon(Icons.chevron_right, color: Colors.grey)),
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
