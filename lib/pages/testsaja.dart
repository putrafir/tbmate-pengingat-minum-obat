import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AlarmWeightScreen extends StatefulWidget {
  const AlarmWeightScreen({super.key});

  @override
  State<AlarmWeightScreen> createState() => _AlarmWeightScreenState();
}

class _AlarmWeightScreenState extends State<AlarmWeightScreen> {
  final TextEditingController weightController = TextEditingController();
  TimeOfDay? selectedTime;
  Timer? alarmTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Pilih waktu alarm
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
      _setAlarm(picked);
    }
  }

  // Set alarm berdasarkan waktu yang dipilih
  void _setAlarm(TimeOfDay time) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    Duration difference = selectedDateTime.difference(now);
    if (difference.isNegative) {
      // Jika waktu sudah lewat, alarm ke hari berikutnya
      difference += const Duration(days: 1);
    }

    alarmTimer?.cancel(); // batalkan alarm sebelumnya
    alarmTimer = Timer(difference, _triggerAlarm);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Alarm disetel pada ${time.format(context)}",
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Jalankan alarm
  Future<void> _triggerAlarm() async {
    // Bunyi alarm (gunakan file suara lokal atau default tone)
    await _audioPlayer.play(AssetSource('sounds/amba.mp3'));

    // Tampilkan popup
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // tidak bisa ditutup selain lewat tombol
        builder: (context) => AlertDialog(
          title: const Text("⏰ Alarm!"),
          content: Text(
            "Sekarang waktunya: ${selectedTime?.format(context) ?? ''}\n"
            "Jangan lupa timbang berat badan kamu!",
          ),
          actions: [
            TextButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
              },
              child: const Text("Stop"),
            ),
            TextButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
                // Lanjutkan alarm setelah 5 menit
                alarmTimer = Timer(const Duration(minutes: 5), _triggerAlarm);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Alarm akan berbunyi lagi dalam 5 menit."),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text("Lanjut (5 menit)"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    alarmTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alarm Berat Badan"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input berat badan
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Berat Badan (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Pilih waktu
            ElevatedButton.icon(
              onPressed: () => _selectTime(context),
              icon: const Icon(Icons.access_time),
              label: Text(selectedTime == null
                  ? "Pilih Waktu Alarm"
                  : "Alarm disetel: ${selectedTime!.format(context)}"),
            ),
          ],
        ),
      ),
    );
  }
}


