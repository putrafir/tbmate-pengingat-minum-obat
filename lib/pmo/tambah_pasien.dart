import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

class CreatePatientAccountPage extends StatefulWidget {
  const CreatePatientAccountPage({super.key});

  @override
  State<CreatePatientAccountPage> createState() =>
      _CreatePatientAccountPageState();
}

class _CreatePatientAccountPageState
    extends State<CreatePatientAccountPage> {
  final fullNameController = TextEditingController();
  final nickNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _createPatientAccount() async {
    final fullName = fullNameController.text.trim();
    final nickName = nickNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
        confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        nickName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password tidak sama"),
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      /// ================= PMO AKTIF =================
      final currentPMO =
          FirebaseAuth.instance.currentUser;

      if (currentPMO == null) {
        throw FirebaseAuthException(
          code: "no-user",
          message: "PMO tidak ditemukan",
        );
      }

      final doctorId = currentPMO.uid;

      /// ================= SECONDARY APP =================
      final secondaryApp =
          await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      final secondaryAuth =
          FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      /// ================= BUAT AKUN PASIEN =================
      final userCredential =
          await secondaryAuth
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final patientUser = userCredential.user!;

      final uniqueId =
          'USR-${DateTime.now().millisecondsSinceEpoch}';

      /// ================= SIMPAN DATA USER =================
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientUser.uid)
          .set({
        'uniqueId': uniqueId,
        'email': email,
        'fullName': fullName,
        'nickName': nickName,
        'role': 'PASIEN',
        'ageGroup': null,
        'weight': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// ================= HUBUNGKAN KE PMO =================
      final doctorRef = FirebaseFirestore.instance
          .collection('doctorPatients')
          .doc(doctorId);

      await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final snapshot =
            await transaction.get(doctorRef);

        if (!snapshot.exists) {
          transaction.set(doctorRef, {
            'patients': [patientUser.uid],
          });
        } else {
          final data = snapshot.data() ?? {};

          final List<dynamic> patients =
              List.from(data['patients'] ?? []);

          if (!patients.contains(patientUser.uid)) {
            patients.add(patientUser.uid);

            transaction.update(doctorRef, {
              'patients': patients,
            });
          }
        }
      });

      /// ================= CLEANUP =================
      await secondaryAuth.signOut();
      await secondaryApp.delete();

      if (!mounted) return;

      setState(() => isLoading = false);

      /// ================= SUCCESS =================
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Berhasil",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Akun pasien $fullName berhasil dibuat.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(
                    '/input-usia',
                    extra: {
                      'patientUid': patientUser.uid,
                      'isFromPMO': true,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2E7D32),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Terjadi kesalahan",
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// ================= HEADER =================
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [

                    /// BACK BUTTON
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
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
                        Icons.person_add_alt_1,
                        size: 60,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// TITLE
                    const Text(
                      "Buat Akun Pasien",
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
                      "PMO dapat langsung membuat akun pasien agar pasien bisa login tanpa setup manual",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= FORM =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F8F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),

                child: Column(
                  children: [

                    /// FULL NAME
                    _buildField(
                      controller: fullNameController,
                      hint: "Nama Panjang Pasien",
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 16),

                    /// NICK NAME
                    _buildField(
                      controller: nickNameController,
                      hint: "Nama Panggilan Pasien",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    /// EMAIL
                    _buildField(
                      controller: emailController,
                      hint: "Email",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    _buildField(
                      controller: passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),

                    const SizedBox(height: 16),

                    /// CONFIRM PASSWORD
                    _buildField(
                      controller: confirmPasswordController,
                      hint: "Konfirmasi Password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),

                    const SizedBox(height: 28),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : _createPatientAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF6EC1E4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Buat Akun Pasien",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}