import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';


class EditSetTime extends StatefulWidget {
  const EditSetTime({
    super.key,
  });

  @override
  State<EditSetTime> createState() => _EditSetTime();
}

class _EditSetTime extends State<EditSetTime> {
  final TextEditingController _hourController =
      TextEditingController(text: "01");
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
    _loadInitialTime();
  }

  // void _loadInitialTime() {
  //   try {
  //     final parts = widget.waktuLama.split('');
  //     final timePart = parts[0].split(':');

  //     _hourController.text = timePart[0];
  //     _minuteController.text = timePart[1];
  //     isAm = parts[1] == 'AM';
  //   } catch (e) {
  //     debugPrint('Error parsing waktu lama: $e');
  //   }
  // }
  Future<void> _loadInitialTime() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('jadwal_obat')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final waktuLama = snapshot.docs.first['waktu_minum'] as String;

      final parts = waktuLama.split(' ');
      final timePart = parts[0].split(':');

      setState(() {
        _hourController.text = timePart[0];
        _minuteController.text = timePart[1];
        isAm = parts[1] == 'AM';
      });
    } catch (e) {
      debugPrint('Error load waktu awal: $e');
    }
  }

  // ================== AMBIL DATA USER ==================
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

  // ================== SIMPAN ==================
  Future<void> _saveToFirestore(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null || beratBadan == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pasien belum lengkap")),
        );
        return;
      }

      final waktu =
          "${_hourController.text}:${_minuteController.text} ${isAm ? "AM" : "PM"}";

      final now = DateTime.now();

      int hour = int.parse(_hourController.text);
      int minute = int.parse(_minuteController.text);

      if (!isAm && hour != 12) {
        hour += 12;
      }
      if (isAm && hour == 12) {
        hour = 0;
      }

      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1 ));
      }

      // await AlarmService.scheduleAlarm(id: 1, dateTime: scheduled);
      
      

      final jadwalCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('jadwal_obat');

      final snapshot = await jadwalCollection.get();

      final batch = FirebaseFirestore.instance.batch();

      // for (var doc in snapshot.docs) {
      //   batch.update(doc.reference, {
      //     'waktu_minum': waktu,
      //     'updatedAt': FieldValue.serverTimestamp(),
      //   });
      // }
      for (var doc in snapshot.docs) {

        batch.update(doc.reference, {
          'waktu_minum': waktu,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final tanggalString = doc['tanggal'];
        final tanggal = DateFormat('yyyy-MM-dd').parse(tanggalString);

        DateTime alarmDate = DateTime(
          tanggal.year,
          tanggal.month,
          tanggal.day,
          hour,
          minute,
        );

        if (alarmDate.isBefore(now)) {
          alarmDate = alarmDate.add(const Duration(days: 1));
        }

        await AlarmService.scheduleAlarm(
          id: doc.id.hashCode,
          date: alarmDate,
        );

      }

      await batch.commit();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jadwal berhasil diubah"),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/main-screen');
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    }
  }

  // ================== VALIDASI JAM ==================
  // void _updateHour() {
  //   int hour = int.tryParse(_hourController.text) ?? 0;
  //   if (hour > 12) hour = 12;
  //   if (hour < 0) hour = 0;

  //   setState(() {
  //     _hourController.text = hour.toString().padLeft(2, '0');
  //   });
  // }
  void _updateHour() {

    int hour = int.tryParse(_hourController.text) ?? 1;

    if (hour > 12) hour = 12;
    if (hour < 1) hour = 1;

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
    setState(() => isAm = am);
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBF4),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER HIJAU
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Setel Waktu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 CONTENT PUTIH
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
                    children: [
                      const SizedBox(height: 25),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Setel Waktu Pengingat",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 TIME PICKER
                      Container(
                        height: 180,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFA6D9E8), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTimeInput(
                                _hourController, "Jam", _updateHour, 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(":",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold)),
                            ),
                            _buildTimeInput(
                                _minuteController, "Menit", _updateMinute, 59),
                            const SizedBox(width: 14),
                            _buildAmPmToggle(isAm),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 BUTTON
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
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Selesai",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== WIDGET JAM ==================
  Widget _buildTimeInput(TextEditingController controller, String label,
      VoidCallback onEditingComplete, int maxValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
            ),
            decoration: const InputDecoration(
                counterText: "", border: InputBorder.none),
            // onEditingComplete: onEditingComplete,
            onEditingComplete: () {

              if (controller == _hourController) {

                int val = int.tryParse(controller.text) ?? 1;

                if (val > 12) val = 12;
                if (val < 1) val = 1;

                controller.text = val.toString().padLeft(2, '0');
              }

              if (controller == _minuteController) {

                int val = int.tryParse(controller.text) ?? 0;

                if (val > 59) val = 59;
                if (val < 0) val = 0;

                controller.text = val.toString().padLeft(2, '0');
              }

            },

          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmPmToggle(bool isAmSelected) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _amPmButton("AM", isAmSelected, true),
          const SizedBox(height: 6),
          _amPmButton("PM", isAmSelected, false),
        ],
      ),
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
          ),
        ),
      ),
    );
  }
}
