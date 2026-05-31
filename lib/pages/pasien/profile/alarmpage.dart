import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmSound {
  final String title;
  final String rawName;
  final IconData icon;

  AlarmSound({
    required this.title,
    required this.rawName,
    required this.icon,
  });
}

class Alarmpage extends StatefulWidget {
  const Alarmpage({super.key});

  @override
  State<Alarmpage> createState() => _AlarmpageState();
}

class _AlarmpageState extends State<Alarmpage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String selectedSound = "classic_alarm";
  String? playingSound;

  final List<AlarmSound> alarmSounds = [
    AlarmSound(
      title: "Classic Alarm",
      rawName: "classic_alarm",
      icon: Icons.alarm,
    ),
    AlarmSound(
      title: "Good Morning",
      rawName: "good_morning",
      icon: Icons.notifications_active,
    ),
    AlarmSound(
      title: "Soft Piano",
      rawName: "soft_piano",
      icon: Icons.music_note,
    ),
    AlarmSound(
      title: "Digital Beep",
      rawName: "digital_beep",
      icon: Icons.graphic_eq,
    ),
    AlarmSound(
      title: "Sunshine Sound",
      rawName: "sunshine",
      icon: Icons.forest,
    ),
    AlarmSound(
      title: "Happy Bird",
      rawName: "happy_bird",
      icon: Icons.flutter_dash,
    ),
    AlarmSound(
      title: "Saxophone",
      rawName: "saxophone",
      icon: Icons.library_music,
    ),
  ];

  Future<void> _loadSelectedSound() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // ================= JIKA ADA DATA =================
      if (doc.exists) {
        final data = doc.data();

        if (data != null && data['alarmSound'] != null) {
          setState(() {
            selectedSound = data['alarmSound'];
          });
        }

        // ================= JIKA BELUM ADA alarmSound =================
        else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'alarmSound': 'classic_alarm',
          }, SetOptions(merge: true));

          setState(() {
            selectedSound = 'classic_alarm';
          });
        }
      }

      // ================= JIKA DOCUMENT BELUM ADA =================
      else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'alarmSound': 'classic_alarm',
        }, SetOptions(merge: true));

        setState(() {
          selectedSound = 'classic_alarm';
        });
      }
    } catch (e) {
      debugPrint("Error load sound: $e");
    }
  }

  Future<void> _saveSelectedSound(String soundName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'alarmSound': soundName,
      }, SetOptions(merge: true));

      setState(() {
        selectedSound = soundName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Sound alarm berhasil diubah",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error save sound: $e");
    }
  }

  Future<void> _previewSound(String soundName) async {
    try {
      // SOUND SAMA DIKLIK
      if (playingSound == soundName) {
        await _audioPlayer.stop();

        setState(() {
          playingSound = null;
        });
        return;
      }

      // STOUP SOUND SEBELUMNYA
      await _audioPlayer.stop();

      setState(() {
        playingSound = soundName;
      });

      await _audioPlayer.play(
        AssetSource('sounds/$soundName.mp3'),
      );

      // auto stop 20 detik
      Future.delayed(const Duration(seconds: 20), () async {
        await _audioPlayer.stop();

        if (mounted) {
          setState(() {
            playingSound = null;
          });
        }
      });
    } catch (e) {
      debugPrint('Error preview sound $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBF4),
      body: SafeArea(
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
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Notifikasi Alarm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih suara alarm pengingat",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= LIST ALARM =================
                    Expanded(
                      child: ListView.builder(
                        itemCount: alarmSounds.length,
                        itemBuilder: (context, index) {
                          final sound = alarmSounds[index];

                          return GestureDetector(
                            onTap: () async {
                              await _saveSelectedSound(sound.rawName);
                            },
                            child: _buildAlarmTile(
                              title: sound.title,
                              duration: "00:20",
                              icon: sound.icon,
                              rawName: sound.rawName,
                              isSelected: selectedSound == sound.rawName,
                              onPriview: () async {
                                await _previewSound(sound.rawName);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ================= INFO BOX =================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Sound alarm akan digunakan untuk semua pengingat minum obat.",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ================= TILE =================

  Widget _buildAlarmTile({
    required String title,
    required String duration,
    required IconData icon,
    required String rawName,
    required VoidCallback onPriview,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ================= ICON =================
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          // ================= TEXT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= BUTTON =================
          GestureDetector(
            onTap: onPriview,
            child:Icon(
              playingSound == rawName
                  ? Icons.pause_circle
                  : Icons.play_circle_outline,
              color: Colors.green,
              size: 34,
            ),
          )
        ],
      ),
    );
  }
}
