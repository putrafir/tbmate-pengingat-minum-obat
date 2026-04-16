import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayat extends StatelessWidget {
  final String namaObat;
  final String dosis;
  final String fase;
  final String status;
  final String waktu;
  final String tanggal;

  const DetailRiwayat({
    super.key,
    required this.namaObat,
    required this.dosis,
    required this.fase,
    required this.status,
    required this.waktu,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    // ================= STATUS DINAMIS =================
    bool isDiminum = status == "Sudah diminum" || status == "Terlambat";
    bool isDilewati = status == "Dilewati";

    Color bgColor;
    String titleText;
    String subtitleText;

    if (isDiminum) {
      bgColor = Colors.green.shade200;
      titleText = "Diminum";
      subtitleText = "Diminum pada pukul $waktu";
    } else if (isDilewati) {
      bgColor = Colors.grey.shade300;
      titleText = "Dilewati";
      subtitleText = "Obat tidak diminum";
    } else {
      bgColor = Colors.orange.shade200;
      titleText = "Belum diminum";
      subtitleText = "Menunggu jadwal";
    }
    // ================= FORMAT TANGGAL =================
    DateTime parsedDate = DateTime.parse(tanggal);
    String formattedDate = DateFormat('d MMMM', 'id_ID').format(parsedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF5),

      // ================= HEADER =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Detail",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= STATUS =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(subtitleText),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= TANGGAL =================
              Text(formattedDate), 

              const SizedBox(height: 16),

              // ================= INFO OBAT =================
              Row(
                children: [
                  const Icon(Icons.medication, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      namaObat,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Container(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.green,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: const Text(
                  //     "Terlambat",
                  //     style: TextStyle(color: Colors.white, fontSize: 10),
                  //   ),
                  // )
                ],
              ),

              const SizedBox(height: 8),
              Text(dosis),
              Text(fase),

              const SizedBox(height: 8),
              Text(
                "4 tablet pukul $waktu",
                style: const TextStyle(color: Colors.blue),
              ),

              const SizedBox(height: 16),

              // ================= DROPDOWN CATATAN (DUMMY) =================
              ExpansionTile(
                title: const Text("Lihat catatan"),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Tidak ada catatan untuk jadwal ini.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}