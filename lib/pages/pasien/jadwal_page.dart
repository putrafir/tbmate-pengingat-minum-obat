import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tbmate_kmipn/pages/pasien/camera_ingestion_page.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/pages/konfirmasi_popup.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';

class JadwalPage extends StatefulWidget {
  final String nickName;
  final bool showPopup;
  final String? docId;

  const JadwalPage(
      {super.key, required this.nickName, this.showPopup = false, this.docId});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime selectedDate = DateTime.now();
  late DateTime _weekAnchor;
  bool _popupTriggered = false;

  @override
  void initState() {
    super.initState();
    _weekAnchor = selectedDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_popupTriggered) return;

    if (widget.showPopup == true && widget.docId != null) {
      final docId = widget.docId;
      _popupTriggered = true;

      Future.microtask(() {
        KonfirmasiPopup.show(
          context: context,
          onConfirm: () {},
          onAlasan: (alasan) async {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null && docId != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('jadwal_obat')
                  .doc(docId)
                  .update({
                "status": "Ditunda",
                "riwayat_tunda": FieldValue.arrayUnion([
                  {
                    "alasan_tunda": alasan,
                    "waktu_tunda": Timestamp.now(),
                  }
                ])
              });

              AlarmService.repeatSnooze(
                DateTime.now().millisecondsSinceEpoch,
                Duration(minutes: 5),
                docId,
              );
            }
          },
        );
      });
    }
  }

  // Ambil 7 hari dalam minggu ini (Minggu–Sabtu)
  List<DateTime> getCurrentWeekDays() {
    final DateTime anchor = _weekAnchor;
    int daysFromSunday = anchor.weekday % 7;
    DateTime startOfWeek = DateTime(anchor.year, anchor.month, anchor.day)
        .subtract(Duration(days: daysFromSunday));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  Stream<QuerySnapshot> getJadwalObat(DateTime selectedDate) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('jadwal_obat')
        .where('tanggal', isEqualTo: formattedDate)
        .snapshots();
  }

  Stream<DocumentSnapshot> getProfilePasien() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    // 🔹 BYPASS TRIK: Sesuaikan jika kamu sedang melakukan testing tanpa login
    final String targetUid = user.uid; // atau pakai UID tester kamu

    return FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .snapshots();
  }

  // Stream<QuerySnapshot> getJadwalObat(DateTime selectedDate) {
  //   // 1. Ambil format tanggal hari yang dipilih di kalender atas
  //   String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

  //   // 2. 🔹 TRIK BYPASS: Pakai UID asli dari Firestore (Samakan dengan yang di MainScreen!)
  //   final user = FirebaseAuth.instance.currentUser;
  //   final String targetUid = user?.uid ?? "eRUHhnCwn9TKpSz5HixEKLvrtMf1";

  //   // 3. Tarik data dari Firebase!
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(targetUid) // 👈 Pastikan pakai targetUid, bukan user.uid
  //       .collection('jadwal_obat')
  //       .where('tanggal', isEqualTo: formattedDate) // 👈 Syarat filter tanggal
  //       .snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = getCurrentWeekDays();
    DateTime today = DateTime.now();

    return Scaffold(
        backgroundColor: const Color(0xFFF5FBF5),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // =================== HEADER ===================
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(46, 125, 50, 1),
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
                            "Sudahkah kamu minum obat hari ini?",
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

            // =================== KONTEN UTAMA ===================
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================== WRAPPER STREAM UNTUK RINGKASAN DATA PROFIL ===================
                  StreamBuilder<DocumentSnapshot>(
                    stream: getProfilePasien(),
                    builder: (context, snapshotProfile) {
                      // 1. Inisialisasi Nilai Default Ringkasan
                      String currentPhase = "Intensif";
                      int obatDiminum = 0;
                      int totalHariFase = 56; // Default Intensif

                      if (snapshotProfile.hasData &&
                          snapshotProfile.data!.exists) {
                        final data = snapshotProfile.data!.data()
                            as Map<String, dynamic>;

                        // Baca fase aktif pasien saat ini
                        currentPhase = data['currentPhase'] ?? 'Intensif';

                        // Ambil stats kepatuhan secara instan tanpa looping dokumen lagi
                        if (currentPhase == 'Lanjutan') {
                          obatDiminum = data['diminumLanjutan'] ?? 0;
                          totalHariFase = data['totalLanjutan'] ?? 48;
                        } else {
                          obatDiminum = data['diminumIntensif'] ?? 0;
                          totalHariFase = data['totalIntensif'] ?? 56;
                        }
                      }

                      // Hitung persentase progress dan sisa hari harian
                      double progress = (totalHariFase > 0)
                          ? (obatDiminum / totalHariFase).clamp(0.0, 1.0)
                          : 0.0;
                      int sisaHari = totalHariFase - obatDiminum;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =================== RINGKASAN ===================
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ringkasan kamu hari ini (Fase $currentPhase)",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 20,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Sisa $sisaHari hari lagi",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "$obatDiminum",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text("Diminum"),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Sisa Hari Pengobatan Fase Aktif
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEBEE),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "$sisaHari",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text("Sisa Hari"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =================== KALENDER ===================
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('MMM yyyy', 'id_ID')
                                          .format(_weekAnchor),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios,
                                              size: 16),
                                          onPressed: () {
                                            setState(() {
                                              _weekAnchor =
                                                  _weekAnchor.subtract(
                                                      const Duration(days: 7));
                                              selectedDate = _weekAnchor;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16),
                                          onPressed: () {
                                            setState(() {
                                              _weekAnchor = _weekAnchor
                                                  .add(const Duration(days: 7));
                                              selectedDate = _weekAnchor;
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: weekDays.map((date) {
                                    bool isSelected =
                                        date.day == selectedDate.day &&
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
                            "Pengobatan kamu",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // =================== LIST OBAT HARIAN (INI YANG TADI HILANG) ===================
                          StreamBuilder<QuerySnapshot>(
                            stream: getJadwalObat(selectedDate),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
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

                              final jadwalList = snapshot.data!.docs;

                              return Column(
                                children: jadwalList.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final namaObat = data['nama_obat'] ?? '-';
                                  final dosis = data['dosis'] ?? '-';
                                  final waktuMinum = data['waktu_minum'] ?? '-';
                                  final fase = data['fase'] ?? '-';
                                  final tanggal = data['tanggal'];

                                  String status =
                                      data['status'] ?? 'Belum diminum';
                                  DateTime now = DateTime.now();
                                  bool isHariIni = tanggal ==
                                      DateFormat('yyyy-MM-dd').format(now);

                                  // Parsing Waktu
                                  DateTime waktuObat;
                                  try {
                                    DateFormat format = DateFormat("HH:mm");
                                    DateTime parsedTime =
                                        format.parse(waktuMinum);
                                    waktuObat = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      parsedTime.hour,
                                      parsedTime.minute,
                                    );
                                  } catch (e) {
                                    waktuObat = now;
                                  }

                                  bool sudahWaktunyaMinum =
                                      now.hour > waktuObat.hour ||
                                          (now.hour == waktuObat.hour &&
                                              now.minute >= waktuObat.minute);

                                  bool tombolDisabled;
                                  String tombolLabel;

                                  if (isHariIni) {
                                    if (status == "Sudah diminum" ||
                                        status == "Terlewati") {
                                      tombolDisabled = false;
                                      tombolLabel = "Detail";
                                    } else {
                                      tombolDisabled = !sudahWaktunyaMinum;
                                      tombolLabel = "Minum";
                                    }
                                  } else {
                                    tombolDisabled = false;
                                    tombolLabel = "Detail";
                                  }

                                  DateTime tglObat =
                                      DateFormat('yyyy-MM-dd').parse(tanggal);
                                  DateTime todayOnly =
                                      DateTime(now.year, now.month, now.day);

                                  // Auto Status Update
                                  if (status != "Sudah diminum" &&
                                      status != "Ditunda") {
                                    if (tglObat.isBefore(todayOnly)) {
                                      status = "Terlewati";
                                    } else {
                                      status = "Belum diminum";
                                    }
                                  }

                                  Color statusColor;
                                  switch (status) {
                                    case "Sudah diminum":
                                      statusColor = Colors.green;
                                      break;
                                    case "Ditunda":
                                      statusColor = Colors.orange;
                                      break;
                                    case "Terlewati":
                                      statusColor = Colors.red;
                                      break;
                                    default:
                                      statusColor = Colors.grey;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/icons/obat.svg',
                                            width: 20,
                                            height: 20),
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
                                                      namaObat,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(dosis,
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13)),
                                              const SizedBox(height: 2),
                                              Text(fase,
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13)),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Pukul $waktuMinum",
                                                      style: const TextStyle(
                                                        color: Colors.lightBlue,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CameraIngestionPage(
                                                                    jadwalDocRef:
                                                                        doc.reference,
                                                                    namaObat:
                                                                        namaObat,
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              String
                                                                  waktuAktual =
                                                                  waktuMinum;
                                                              if (data[
                                                                      'waktu_verifikasi'] !=
                                                                  null) {
                                                                DateTime
                                                                    verifDate =
                                                                    (data['waktu_verifikasi']
                                                                            as Timestamp)
                                                                        .toDate();
                                                                waktuAktual =
                                                                    DateFormat(
                                                                            'HH:mm')
                                                                        .format(
                                                                            verifDate);
                                                              }

                                                              // 🔹 OPER PATH DOKUMEN UTAMA KE ROUTER
                                                              context.pushNamed(
                                                                'detail-riwayat',
                                                                extra: {
                                                                  'namaObat':
                                                                      namaObat,
                                                                  'dosis':
                                                                      dosis,
                                                                  'fase': fase,
                                                                  'status':
                                                                      status,
                                                                  'waktu':
                                                                      waktuMinum,
                                                                  'tanggal':
                                                                      tanggal,
                                                                  'waktuVerifikasi':
                                                                      waktuAktual,
                                                                  'riwayatTunda':
                                                                      data['riwayat_tunda'] ??
                                                                          [],
                                                                  // 👇 Kunci optimasi baru: kirim path dokumennya
                                                                  'jadwalDocPath':
                                                                      doc.reference
                                                                          .path,
                                                                },
                                                              );
                                                            }
                                                          },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          tombolDisabled
                                                              ? Colors
                                                                  .grey.shade300
                                                              : (tombolLabel ==
                                                                      "Detail"
                                                                  ? Colors.green
                                                                      .shade100
                                                                  : const Color(
                                                                      0xFFB3E5FC)),
                                                      foregroundColor:
                                                          Colors.black,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
