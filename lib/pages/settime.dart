import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';

class SetWaktu extends StatefulWidget {
  const SetWaktu({super.key});

  @override
  State<SetWaktu> createState() => _SetWaktuState();
}

class _SetWaktuState extends State<SetWaktu> {
  final TextEditingController _hourController =
      TextEditingController(text: "00");
  final TextEditingController _minuteController =
      TextEditingController(text: "00");
  bool isAm = true;
  bool _isLoadingPasien = true;
  double? beratBadan;
  String? uniqueId;

  @override
  void initState() {
    super.initState();
    _ambilDataPasien();
  }

  // Future<void> _ambilDataPasien() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final doc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: user.email)
  //       .limit(1)
  //       .get();

  //   if (doc.docs.isNotEmpty) {
  //     final data = doc.docs.first.data();
  //     setState(() {
  //       beratBadan = (data['weight'] as num?)?.toDouble();
  //       uniqueId = data['uniqueId'];
  //     });
  //   }
  // }
  Future<void> _ambilDataPasien() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingPasien = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        beratBadan = (data?['weight'] as num?)?.toDouble();
        uniqueId = data?['uniqueId'];
      }
    } catch (e) {
      debugPrint('❌ Error ambil pasien: $e');
    }

    if (mounted) {
      setState(() => _isLoadingPasien = false);
    }
  }

  Future<void> _saveToFirestore(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8ED8F8)),
          );
        },
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || beratBadan == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pasien belum lengkap")),
        );
        return;
      }

      // Tentukan dosis berdasarkan berat badan
      String tahapIntensif = "";
      String tahapLanjutan = "";
      String namaObat = "";
      int jumlahTablet = 0;

      if (beratBadan! >= 5 && beratBadan! <= 9) {
        tahapIntensif = "1 tablet RHZ (75/50/150)";
        tahapLanjutan = "1 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 1;
      } else if (beratBadan! >= 10 && beratBadan! <= 14) {
        tahapIntensif = "2 tablet RHZ (75/50/150)";
        tahapLanjutan = "2 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 2;
      } else if (beratBadan! >= 15 && beratBadan! <= 19) {
        tahapIntensif = "3 tablet RHZ (75/50/150)";
        tahapLanjutan = "3 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 3;
      } else if (beratBadan! >= 20 && beratBadan! <= 30) {
        tahapIntensif = "4 tablet RHZ (75/50/150)";
        tahapLanjutan = "4 tablet RH (75/50)";
        namaObat = "RHZ / RH";
        jumlahTablet = 4;
      } else if (beratBadan! >= 31 && beratBadan! <= 37) {
        tahapIntensif = "2 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "2 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 2;
      } else if (beratBadan! >= 38 && beratBadan! <= 54) {
        tahapIntensif = "3 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "3 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 3;
      } else if (beratBadan! >= 55 && beratBadan! <= 70) {
        tahapIntensif = "4 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "4 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 4;
      } else if (beratBadan! >= 71) {
        tahapIntensif = "5 tablet RHZE (150/75/400/275)";
        tahapLanjutan = "5 tablet RH (150/150)";
        namaObat = "4 KDT RHZE";
        jumlahTablet = 5;
      }

      final waktu =
          "${_hourController.text}:${_minuteController.text} ${isAm ? "AM" : "PM"}";

      final jadwalCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('jadwal_obat');

      final now = DateTime.now();
      int hour = int.parse(_hourController.text);
      int minute = int.parse(_minuteController.text);

      if (!isAm && hour != 12) {
        hour += 12;
      }

      if (isAm && hour == 12) {
        hour = 0;
      }

      // Fase Intensif (56 hari)
      // for (int i = 0; i < 56; i++) {
      //   final tgl = now.add(Duration(days: i));
      //   await jadwalCollection.add({
      //     'userId': user.uid,
      //     'nama_obat': namaObat,
      //     'fase': 'Intensif',
      //     'dosis': tahapIntensif,
      //     'jumlah_tablet': jumlahTablet,
      //     'waktu_minum': waktu,
      //     'status': 'Belum diminum',
      //     'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
      //     'berat_badan': beratBadan,
      //     'createdAt': FieldValue.serverTimestamp(),
      //   });
      // }
      for (int i = 0; i < 56; i++) {
        final dateOnly = now.add(Duration(days: i));

        final tgl = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          hour,
          minute,
        );

        final docRef = await jadwalCollection.add({
          'userId': user.uid,
          'nama_obat': namaObat,
          'fase': 'Intensif',
          'dosis': tahapIntensif,
          'jumlah_tablet': jumlahTablet,
          'waktu_minum': waktu,
          'status': 'Belum diminum',
          'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
          'berat_badan': beratBadan,
          'createdAt': FieldValue.serverTimestamp(),
        });
      
          await AlarmService.scheduleAlarm(
            id: docRef.id.hashCode,
            date: tgl,
          );
      }

      // Fase Lanjutan (3x seminggu, 16 minggu)
      // for (int week = 0; week < 16; week++) {
      //   for (int day = 0; day < 7; day++) {
      //     if (day == 1 || day == 3 || day == 5) {
      //       final tgl = now.add(Duration(days: 56 + (week * 7) + day));
      //       await jadwalCollection.add({
      //         'userId': user.uid,
      //         'nama_obat': namaObat,
      //         'fase': 'Lanjutan',
      //         'dosis': tahapLanjutan,
      //         'jumlah_tablet': jumlahTablet,
      //         'waktu_minum': waktu,
      //         'status': 'Belum diminum',
      //         'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
      //         'berat_badan': beratBadan,
      //         'createdAt': FieldValue.serverTimestamp(),
      //       });
      //     }
      //   }
      // }
      for (int week = 0; week < 16; week++) {

        for (int day = 0; day < 7; day++) {

          if (day == 1 || day == 3 || day == 5) {

            final tgl = now.add(Duration(days: 56 + (week * 7) + day));

            final docRef = await jadwalCollection.add({
              'userId': user.uid,
              'nama_obat': namaObat,
              'fase': 'Lanjutan',
              'dosis': tahapLanjutan,
              'jumlah_tablet': jumlahTablet,
              'waktu_minum': waktu,
              'status': 'Belum diminum',
              'tanggal': DateFormat('yyyy-MM-dd').format(tgl),
              'berat_badan': beratBadan,
              'createdAt': FieldValue.serverTimestamp(),
            });

            await AlarmService.scheduleAlarm(
              id: docRef.id.hashCode,
              date: tgl,
            );

          }

        }

      }



      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jadwal minum obat berhasil dibuat!"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/main-screen');
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: $e")),
      );
    }
  }

  void _updateHour() {
    int hour = int.tryParse(_hourController.text) ?? 0;
    if (hour > 12) hour = 12;
    if (hour < 0) hour = 0;
    setState(() {
      _hourController.text = hour.toString().padLeft(2, '0');
    });
  }

  void _updateMinute() {
    int minute = int.tryParse(_minuteController.text) ?? 0;
    if (minute > 59) minute = 59;
    if (minute < 0) minute = 0;
    setState(() {
      _minuteController.text = minute.toString().padLeft(2, '0');
    });
  }

  void _toggleAmPm(bool am) {
    setState(() {
      isAm = am;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kPrimaryGreen,
      body: Column(
        children: [
          AuthHeader(
            imagePath: 'assets/tibi/tibi-happy.png',
            title: 'SETEL WAKTU',
            subtitle:
                'Atur waktu pengingatmu agar TBMATE bisa bantu kamu minum obat tepat waktu.',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Setel Waktu Pengingat",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFA6D9E8), width: 2),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeInput(
                                _hourController, "Jam", _updateHour, 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(":",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ),
                            _buildTimeInput(
                                _minuteController, "Menit", _updateMinute, 59),
                            const SizedBox(width: 14),
                            _buildAmPmToggle(isAm),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoadingPasien
                            ? null
                            : () => _saveToFirestore(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8ED8F8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Selesai",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20), // ruang bawah aman
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label,
      VoidCallback onEditingComplete, int maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.0),
            decoration: const InputDecoration(
                counterText: "", border: InputBorder.none),
            onChanged: (value) {
              if (value.length == 2) {
                int val = int.tryParse(value) ?? 0;
                if (val > maxValue) {
                  val = maxValue;
                  controller.text = val.toString().padLeft(2, '0');
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length));
                }
              }
            },
            onEditingComplete: () {
              if (controller.text.isEmpty) controller.text = "00";
              int val = int.tryParse(controller.text) ?? 0;
              if (val > maxValue) val = maxValue;
              controller.text = val.toString().padLeft(2, '0');
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
              onEditingComplete();
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmPmToggle(bool isAm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _amPmButton("AM", isAm, true),
        const SizedBox(height: 6),
        _amPmButton("PM", isAm, false),
      ],
    );
  }

  Widget _amPmButton(String label, bool isAmSelected, bool isThisAm) {
    final selected = (isThisAm && isAmSelected) || (!isThisAm && !isAmSelected);

    return GestureDetector(
      onTap: () => _toggleAmPm(isThisAm),
      child: Container(
        width: 40,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: selected ? Colors.blue : Colors.grey.shade400),
          color: selected ? Colors.blue.shade100 : Colors.grey.shade100,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
