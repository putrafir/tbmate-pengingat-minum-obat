import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tbmate_kmipn/pages/camera_ingestion_page.dart';
import 'package:go_router/go_router.dart';

class JadwalPage extends StatefulWidget {
  final String nickName;
  const JadwalPage({super.key, required this.nickName});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime selectedDate = DateTime.now();
  late DateTime _weekAnchor;

  @override
  void initState() {
    super.initState();
    _weekAnchor = selectedDate;
  }

  // Ambil 7 hari dalam minggu ini (Minggu–Sabtu)
  List<DateTime> getCurrentWeekDays() {
    final DateTime anchor = _weekAnchor;
    int daysFromSunday = anchor.weekday % 7;
    DateTime startOfWeek = DateTime(anchor.year, anchor.month, anchor.day)
        .subtract(Duration(days: daysFromSunday));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Stream<QuerySnapshot> getJadwalObat(DateTime selectedDate) {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     return const Stream.empty();
  //   }

  //   String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('jadwal_obat')
  //       .where('tanggal', isEqualTo: formattedDate)
  //       .snapshots();
  // }

  Stream<QuerySnapshot> getJadwalObat(DateTime selectedDate) {
    // 1. Ambil format tanggal hari yang dipilih di kalender atas
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // 2. 🔹 TRIK BYPASS: Pakai UID asli dari Firestore (Samakan dengan yang di MainScreen!)
    final user = FirebaseAuth.instance.currentUser;
    final String targetUid = user?.uid ?? "eRUHhnCwn9TKpSz5HixEKLvrtMf1";

    // 3. Tarik data dari Firebase!
    return FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid) // 👈 Pastikan pakai targetUid, bukan user.uid
        .collection('jadwal_obat')
        .where('tanggal', isEqualTo: formattedDate) // 👈 Syarat filter tanggal
        .snapshots();
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
                  // =================== KOTAK SARAN DOKTER ===================
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Image.asset('assets/images/icondoctor.png', height: 80),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Butuh saran dokter?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: null,
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color(0xFF2E7D32)),
                                      foregroundColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Konsultasi Sekarang",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =================== WRAPPER STREAM UNTUK RINGKASAN & JADWAL ===================
                  StreamBuilder<QuerySnapshot>(
                    stream: getJadwalObat(selectedDate),
                    builder: (context, snapshot) {
                      // 1. Hitung Ringkasan Dinamis
                      int obatDiminum = 0;
                      int obatDilewati = 0;
                      List<QueryDocumentSnapshot> jadwalList = [];

                      if (snapshot.hasData) {
                        jadwalList = snapshot.data!.docs;
                        for (var doc in jadwalList) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['status'] == 'Sudah diminum') {
                            obatDiminum++;
                          } else if (data['status'] == 'Terlambat') {
                            obatDilewati++;
                          }
                        }
                      }

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
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ringkasan kamu hari ini",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAE9EE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(
                                          "62 hari", // Bisa dibuat dinamis nanti jika ada data durasi total
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB2DFDB),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              "$obatDiminum",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Diminum",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F1F1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              "$obatDilewati",
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Dilewati",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                              ),
                                            ),
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

                          // =================== LIST OBAT ===================
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ))
                          else if (jadwalList.isEmpty)
                            Container(
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
                            )
                          else
                            Column(
                              children: jadwalList.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final namaObat = data['nama_obat'] ?? '-';
                                final dosis = data['dosis'] ?? '-';
                                final waktuMinum = data['waktu_minum'] ?? '-';
                                final status =
                                    data['status'] ?? 'Belum diminum';
                                final fase = data['fase'] ?? '-';
                                final tanggal = data['tanggal'] ??
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now());

                                DateTime now = DateTime.now();
                                bool isHariIni = tanggal ==
                                    DateFormat('yyyy-MM-dd').format(now);

                                // 2. Fix Parsing Waktu dari Firebase (menggunakan HH:mm)
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
                                  waktuObat = now; // Fallback jika format salah
                                }

                                bool sudahWaktunyaMinum =
                                    now.hour > waktuObat.hour ||
                                        (now.hour == waktuObat.hour &&
                                            now.minute >= waktuObat.minute);

                                bool tombolDisabled;
                                String tombolLabel;

                                // 3. Fix Logika Tombol Detail
                                if (isHariIni) {
                                  if (status == "Sudah diminum" || status == "Terlewati") {
                                    tombolDisabled = false;
                                    tombolLabel = "Detail";
                                  } else {
                                    tombolDisabled = !sudahWaktunyaMinum;
                                    ;
                                    tombolLabel = "Minum";
                                  }
                                  //       if (status == "Belum diminum") {
                                  //   tombolDisabled = !sudahWaktunyaMinum;
                                  //   tombolLabel = "Minum";
                                  // } else {
                                  //   tombolDisabled = false;
                                  //   tombolLabel = "Detail";
                                  // }
                                } else {
                                  tombolDisabled =
                                      false; // Diubah jadi false supaya bisa diklik
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                            // 🔹 UBAH BAGIAN INI: Arahkan ke Halaman Kamera AI
                                                            // Kita kirimkan doc.reference agar halaman kamera bisa
                                                            // update status setelah AI mendeteksi obat diminum.
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
                                                            final data = doc
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>;

                                                            // 🔹 TAMBAHAN BARU: Ambil waktu asli dia minum dari Firestore
                                                            String waktuAktual =
                                                                waktuMinum; // Default ke jadwal awal
                                                            if (data[
                                                                    'waktu_verifikasi'] !=
                                                                null) {
                                                              // Ubah format Timestamp dari Firebase jadi teks Jam:Menit
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

                                                            context.pushNamed(
                                                              'detail-riwayat',
                                                              extra: {
                                                                'namaObat':
                                                                    namaObat,
                                                                'dosis': dosis,
                                                                'fase': fase,
                                                                'status':
                                                                    status,
                                                                'waktu':

                                                                    waktuMinum, // Ini jadwal asli (misal 13:00)
                                                                'tanggal':
                                                                    tanggal,

                                                                'buktiFoto': data[
                                                                    'bukti_foto'],
                                                                'verifikasiAi':
                                                                    data[
                                                                        'verifikasi_ai'],
                                                                'skorAi': data[
                                                                    'ai_confidence_score'],

                                                                // 🔹 KIRIM WAKTU AKTUAL KE ROUTER
                                                                'waktuVerifikasi':
                                                                    waktuAktual,

                                                                'riwayat_tunda': data['riwayat_tunda'] ?? [],


                                                              },
                                                            );
                                                          }
                                                        },
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                              }).toList(),
                            )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
