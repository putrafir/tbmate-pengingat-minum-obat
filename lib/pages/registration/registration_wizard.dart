import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/pages/registration/beratbadan.dart';
import 'package:tbmate_kmipn/pages/registration/input_role.dart';
import 'package:tbmate_kmipn/pages/registration/inputname.dart';
import 'package:tbmate_kmipn/pages/registration/settime.dart';
import 'package:tbmate_kmipn/pages/registration/welcome_page.dart';

// 🔥 IMPORT FILE AGE STEP
import 'package:tbmate_kmipn/pages/registration/inputusia.dart';

class RegistrationWizard extends StatefulWidget {
  const RegistrationWizard({super.key});

  @override
  State<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends State<RegistrationWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // --- TEMPAT PENYIMPANAN DATA SEMENTARA ---
  String? role;
  String? fullName;
  String? nickName;
  String? ageGroup; // 🔹 Tambahkan variabel ageGroup
  int? weight;
  String? reminderTime;

  // Navigasi Halaman
  void _nextStep() {
    FocusScope.of(context).unfocus(); // Tutup keyboard jika ada
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep--);
  }

  // =========================================================
  // 🔥 FUNGSI BATCH WRITE (SIMPAN SEMUA DALAM 1 TEMBAKAN)
  // =========================================================
  Future<void> _finishRegistration(String timeValue) async {
    setState(() {
      reminderTime = timeValue;
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final jadwalCollection = userRef.collection('jadwal_obat');

    try {
      // 1. Tentukan Dosis Berdasarkan Berat
      String tahapIntensif = "";
      String tahapLanjutan = "";
      String namaObat = "";
      int jumlahTablet = 0;
      double bb = weight!.toDouble();

      if (bb >= 5 && bb <= 9) {
        tahapIntensif = "1 tablet RHZ (75/50/150)";
        tahapLanjutan = "1 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 1;
      } else if (bb >= 10 && bb <= 14) {
        tahapIntensif = "2 tablet RHZ (75/50/150)";
        tahapLanjutan = "2 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 2;
      } else if (bb >= 15 && bb <= 19) {
        tahapIntensif = "3 tablet RHZ (75/50/150)";
        tahapLanjutan = "3 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 3;
      } else if (bb >= 20 && bb <= 30) {
        tahapIntensif = "4 tablet RHZ (75/50/150)";
        tahapLanjutan = "4 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 4;
      } else if (bb >= 31 && bb <= 37) {
        tahapIntensif = "2 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "2 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 2;
      } else if (bb >= 38 && bb <= 54) {
        tahapIntensif = "3 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "3 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 3;
      } else if (bb >= 55 && bb <= 70) {
        tahapIntensif = "4 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "4 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 4;
      } else if (bb >= 71) {
        tahapIntensif = "5 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "5 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 5;
      }

      // 2. Siapkan Profil User + Optimasi Dashboard
      batch.set(
          userRef,
          {
            'uniqueId': 'USR-${DateTime.now().millisecondsSinceEpoch}',
            'email': user.email,
            'role': role,
            'fullName': fullName,
            'nickName': nickName,
            'ageGroup': ageGroup, // 🔹 Pastikan ageGroup tersimpan
            'weight': weight,
            'reminderTime': reminderTime,
            'createdAt': FieldValue.serverTimestamp(),
            'currentPhase': 'Intensif',
            'totalIntensif': 56,
            'diminumIntensif': 0,
            'totalLanjutan': 48,
            'diminumLanjutan': 0,
            'status': 'Aktif',
            'isSetupComplete': true
          },
          SetOptions(merge: true));

      // Parsing Waktu
      final now = DateTime.now();
      DateFormat format = DateFormat("hh:mm a");
      DateTime parsedTime = format.parse(reminderTime!);
      int hour = parsedTime.hour;
      int minute = parsedTime.minute;

      // 3. Generate 56 Hari Intensif ke dalam Batch
      for (int i = 0; i < 56; i++) {
        final dateOnly = now.add(Duration(days: i));
        final tgl =
            DateTime(dateOnly.year, dateOnly.month, dateOnly.day, hour, minute);
        final docRef = jadwalCollection.doc();

        batch.set(docRef, {
          'userId': user.uid,
          'nama_obat': namaObat,
          'fase': 'Intensif',
          'dosis': tahapIntensif,
          'jumlah_tablet': jumlahTablet,
          'waktu_minum': reminderTime,
          'status': 'Belum diminum',
          'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
          'berat_badan': weight,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. Generate 16 Minggu Lanjutan ke dalam Batch
      for (int week = 0; week < 16; week++) {
        for (int day = 0; day < 7; day++) {
          if (day == 1 || day == 3 || day == 5) {
            final dateOnly = now.add(Duration(days: 56 + (week * 7) + day));
            final tgl = DateTime(
                dateOnly.year, dateOnly.month, dateOnly.day, hour, minute);
            final docRef = jadwalCollection.doc();

            batch.set(docRef, {
              'userId': user.uid,
              'nama_obat': namaObat,
              'fase': 'Lanjutan',
              'dosis': tahapLanjutan,
              'jumlah_tablet': jumlahTablet,
              'waktu_minum': reminderTime,
              'status': 'Belum diminum',
              'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
              'berat_badan': weight,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      // 5. EKSEKUSI PENYIMPANAN
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil membuat jadwal!")),
        );
        if (role == 'PMO') {
          context.go('/pmo-main-screen');
        } else {
          context.go('/main-screen');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Kunci swipe
            children: [
              // STEP 1: PILIH ROLE
              RoleStep(
                onNext: (selectedRole) {
                  role = selectedRole;
                  _nextStep();
                },
              ),

              // STEP 2: INPUT NAMA
              NameStep(
                onNext: (full, nick) async {
                  fullName = full;
                  nickName = nick;

                  // 🔥 JIKA ROLE PMO
                  if (role == 'PMO') {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'uniqueId':
                            'USR-${DateTime.now().millisecondsSinceEpoch}',
                        'email': user.email,
                        'role': role,
                        'fullName': fullName,
                        'nickName': nickName,
                        'createdAt': FieldValue.serverTimestamp(),
                        'isSetupComplete': true,
                      }, SetOptions(merge: true));

                      if (context.mounted) {
                        context.go('/pmo-main-screen');
                      }
                    }
                  } else {
                    // 🔥 PASIEN LANJUT FLOW NORMAL
                    _nextStep();
                  }
                },
              ),

              // STEP 3: WELCOME GREETING
              WelcomeStep(
                nickName: nickName ?? "",
                onNext: () {
                  _nextStep();
                },
              ),

              // 🔥 STEP 4: PILIH USIA (Ini yang tadi kelupaan!)
              AgeStep(
                onNext: (selectedAge) {
                  ageGroup = selectedAge;
                  _nextStep();
                },
              ),

              // STEP 5: PILIH BERAT BADAN
              WeightStep(
                onNext: (selectedWeight) {
                  weight = selectedWeight;
                  _nextStep();
                },
              ),

              // STEP 6: SET WAKTU MINUM OBAT
              TimeStep(
                isLoading: _isLoading,
                onFinish: (time) {
                  _finishRegistration(time);
                },
              ),
            ],
          ),

          // Tombol Kembali Global (Hanya muncul jika bukan step 1 dan sedang tidak loading)
          if (_currentStep > 0 && !_isLoading)
            Positioned(
              top: 50,
              left: 16,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: _prevStep,
              ),
            ),
        ],
      ),
    );
  }
}
