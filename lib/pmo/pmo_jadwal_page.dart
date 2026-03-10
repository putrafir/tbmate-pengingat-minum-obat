import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart'; // Untuk gabung stream

class PmoJadwalPage extends StatefulWidget {
  final String nickName;
  const PmoJadwalPage({super.key, required this.nickName});

  @override
  State<PmoJadwalPage> createState() => _PmoJadwalPageState();
}

class _PmoJadwalPageState extends State<PmoJadwalPage> {
  DateTime selectedDate = DateTime.now();

  // Ambil 7 hari dalam minggu ini (Minggu–Sabtu)
  List<DateTime> getCurrentWeekDays() {
    DateTime now = DateTime.now();
    int weekday = now.weekday; // Senin = 1, Minggu = 7
    DateTime startOfWeek = now.subtract(Duration(days: weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // 🔹 Ambil semua pasien PMO
  Future<List<String>> getPatientIds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final doc = await FirebaseFirestore.instance
        .collection('doctorPatients')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['patients'] ?? []);
    }
    return [];
  }

  // 🔹 Ambil nama pasien dari UID
  Future<String> getPatientName(String patientId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['nickName'] ?? data['fullName'] ?? 'Pasien';
    }
    return 'Pasien';
  }

  // 🔹 Ambil semua jadwal semua pasien untuk tanggal terpilih
  Stream<List<Map<String, dynamic>>> getAllJadwal(
      DateTime selectedDate) async* {
    final patientIds = await getPatientIds();
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    if (patientIds.isEmpty) {
      yield [];
      return;
    }

    List<Stream<QuerySnapshot>> streams = patientIds.map((id) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('jadwal_obat')
          .where('tanggal', isEqualTo: formattedDate)
          .snapshots();
    }).toList();

    await for (final snapshots in StreamZip(streams)) {
      List<Map<String, dynamic>> jadwalList = [];
      for (int i = 0; i < snapshots.length; i++) {
        final docs = snapshots[i].docs;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['patientId'] = patientIds[i];
          data['docRef'] = doc.reference;
          jadwalList.add(data);
        }
      }
      yield jadwalList;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = getCurrentWeekDays();
    DateTime today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================== HEADER ===================
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/images/icon2.png',
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hai ${widget.nickName}!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Pastikan Pasien Kamu Sudah Minum Obat Hari Ini Ya!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // =================== KALENDER ===================
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM yyyy', 'id_ID')
                                  .format(DateTime.now()),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.arrow_back_ios, size: 16),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("MIN"),
                            Text("SEN"),
                            Text("SEL"),
                            Text("RAB"),
                            Text("KAM"),
                            Text("JUM"),
                            Text("SAB"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weekDays.map((date) {
                            bool isSelected = date.day == selectedDate.day &&
                                date.month == selectedDate.month &&
                                date.year == selectedDate.year;
                            bool isToday = date.day == today.day &&
                                date.month == today.month &&
                                date.year == today.year;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDate = date;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.lightBlue
                                      : isToday
                                          ? Colors.green.shade100
                                          : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "${date.day}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? Colors.green.shade800
                                            : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Pengobatan Pasien kamu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 🔹 StreamBuilder gabungan semua jadwal pasien
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getAllJadwal(selectedDate),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final jadwalList = snapshot.data!;
                      if (jadwalList.isEmpty) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5FBF5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                "Tidak ada jadwal minum obat di tanggal ini",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Image.asset(
                                'assets/images/icontasknull.png',
                                height: 200,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: jadwalList.map((jadwal) {
                          final namaObat = jadwal['nama_obat'] ?? '-';
                          final dosis = jadwal['dosis'] ?? '-';
                          final jumlahTablet =
                              jadwal['jumlah_tablet']?.toString() ?? '-';
                          final waktuMinum = jadwal['waktu_minum'] ?? '-';
                          final status = jadwal['status'] ?? 'Belum diminum';
                          final fase = jadwal['fase'] ?? '-';
                          final tanggal = jadwal['tanggal'] ??
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          final patientId = jadwal['patientId'] ?? '';
                          final docRef = jadwal['docRef'] as DocumentReference;

                          DateTime now = DateTime.now();
                          bool isHariIni =
                              tanggal == DateFormat('yyyy-MM-dd').format(now);

                          // Parsing waktu obat
                          DateTime waktuObat;
                          try {
                            DateFormat format = DateFormat("HH:mm");
                            DateTime parsedTime = format.parse(waktuMinum);
                            waktuObat = DateTime(now.year, now.month, now.day,
                                parsedTime.hour, parsedTime.minute);
                          } catch (_) {
                            waktuObat = now;
                          }

                          bool sudahWaktunyaMinum = now.isAfter(waktuObat);
                          bool tombolDisabled;
                          String tombolLabel;

                          if (isHariIni) {
                            if (status == "Belum diminum") {
                              tombolDisabled = !sudahWaktunyaMinum;
                              tombolLabel = "Minum";
                            } else {
                              tombolDisabled = false;
                              tombolLabel = "Detail";
                            }
                          } else {
                            tombolDisabled = true;
                            tombolLabel = "Detail";
                          }

                          Color statusColor;
                          switch (status) {
                            case "Sudah diminum":
                              statusColor = Colors.green;
                              break;
                            case "Terlambat":
                              statusColor = Colors.redAccent;
                              break;
                            default:
                              statusColor = Colors.orangeAccent;
                          }

                          return FutureBuilder<String>(
                            future: getPatientName(patientId),
                            builder: (context, nameSnapshot) {
                              final patientName = nameSnapshot.data ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset('assets/icons/obat.svg',
                                        width: 20, height: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "$namaObat ($patientName)",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                status,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dosis,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            fase,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Pukul $waktuMinum",
                                                  style: const TextStyle(
                                                    color: Colors.lightBlue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: tombolDisabled
                                                    ? null
                                                    : () async {
                                                        if (tombolLabel ==
                                                            "Minum") {
                                                          await docRef.update({
                                                            'status':
                                                                'Sudah diminum'
                                                          });
                                                        } else {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                AlertDialog(
                                                              title: Text(
                                                                  "$namaObat ($patientName)"),
                                                              content: Text(
                                                                  "Fase: $fase\nDosis: $dosis\nStatus: $status"),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: const Text(
                                                                      "Tutup"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      tombolDisabled
                                                          ? Colors.grey.shade300
                                                          : const Color(
                                                              0xFFB3E5FC),
                                                  foregroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  minimumSize:
                                                      const Size(80, 36),
                                                ),
                                                child: Text(
                                                  tombolLabel,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
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
