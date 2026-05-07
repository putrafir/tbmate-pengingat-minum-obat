import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditPhoneNumberPage extends StatefulWidget {
  const EditPhoneNumberPage({super.key});

  @override
  State<EditPhoneNumberPage> createState() =>
      _EditPhoneNumberPageState();
}

class _EditPhoneNumberPageState
    extends State<EditPhoneNumberPage> {
  final TextEditingController _phoneController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  // 🔹 Ambil nomor HP dari Firestore
  Future<void> _loadPhoneNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users') // sesuaikan dengan firestore kamu
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();

          if (data != null &&
              data.containsKey('phoneNumber')) {
            _phoneController.text =
                data['phoneNumber'] ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint("Error load nomor HP: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 🔹 Simpan nomor HP ke Firestore
  Future<void> _updatePhoneNumber() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nomor handphone tidak boleh kosong"),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'phoneNumber': phone,
          'updatedAt':
              FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("✅ Nomor handphone berhasil diperbarui"),
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Error update nomor HP: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Gagal memperbarui nomor handphone"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Ganti No. Handphone',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 🔹 BODY
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: const Color(0xFFF9FFF6),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    _buildPhoneNumberInput(),
                    const SizedBox(height: 32),
                    _buildEditButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  // 🔹 INPUT NOMOR HP
  Widget _buildPhoneNumberInput() {
    return TextFormField(
      controller: _phoneController,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(
            Icons.call,
            color: Colors.black54,
            size: 24,
          ),
        ),
        hintText: 'Masukkan nomor handphone baru',
        enabledBorder: const UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black45, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green.shade700,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  // 🔹 BUTTON EDIT
  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isSaving ? null : _updatePhoneNumber,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF79D5F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}