import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNamaPage extends StatefulWidget {
  const EditNamaPage({Key? key}) : super(key: key);

  @override
  State<EditNamaPage> createState() => _EditNamaPageState();
}

class _EditNamaPageState extends State<EditNamaPage> {
  final TextEditingController _namaPanjangController = TextEditingController();
  final TextEditingController _namaPanggilanController =
      TextEditingController();

  String _initialFullName = '';
  String _initialNickName = '';
  bool _isSaving = false;

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();

      final fullName = data?['fullName'] ?? '';
      final nickName = data?['nickName'] ?? '';

      _namaPanjangController.text = fullName;
      _namaPanggilanController.text = nickName;

      _initialFullName = fullName;
      _initialNickName = nickName;
    }
  }

  Future<void> _saveName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newFullName = _namaPanjangController.text.trim();
    final newNickName = _namaPanggilanController.text.trim();

    final isChanged =
        newFullName != _initialFullName || newNickName != _initialNickName;

    if (!isChanged) {
      context.go(
        '/akun',
        extra: {
          'fullName': _initialFullName,
          'uniqueId': user.uid,
          'role': 'pasien',
        },
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fullName': newFullName,
        'nickName': newNickName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('nama berhasil diubah'),
          backgroundColor: Colors.green,
        ),
      );

      context.go(
        '/akun',
        extra: {
          'fullName': newFullName,
          'uniqueId': user.uid,
          'role': 'pasien',
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBF4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Edit Nama",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Form Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nama panjang",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _namaPanjangController,
                    decoration: InputDecoration(
                      hintText: "Masukkan nama lengkap",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.black12, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Nama panggilan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _namaPanggilanController,
                    decoration: InputDecoration(
                      hintText: "Masukkan nama panggilan",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.black12, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 Tombol Lanjut
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent.shade100,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Lanjut",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
}
