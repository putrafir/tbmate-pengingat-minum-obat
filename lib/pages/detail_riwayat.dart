import 'dart:convert'; // 🔹 Wajib untuk base64Decode
import 'dart:typed_data'; // 🔹 Wajib untuk Uint8List
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayat extends StatelessWidget {
  final String namaObat;
  final String dosis;
  final String fase;
  final String status;
  final String waktu;
  final String tanggal;

  // 🔹 Tambahan Parameter untuk Menerima Data AI & Foto dari Firestore
  final Map<String, dynamic>? buktiFoto;
  final String? verifikasiAi;
  final double? skorAi;
  final String? waktuVerifikasi;

  const DetailRiwayat({
    super.key,
    required this.namaObat,
    required this.dosis,
    required this.fase,
    required this.status,
    required this.waktu,
    required this.tanggal,
    this.buktiFoto,
    this.verifikasiAi,
    this.skorAi,
    this.waktuVerifikasi,
  });

  // ==============================================================
  // 🔹 FUNGSI AJAIB: Menyulap Teks Base64 Kembali Menjadi Gambar
  // ==============================================================
  Widget _buildBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Container(
        height: 140,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text("Tidak ada\nfoto",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      );
    }

    try {
      // Buang header "data:image/jpeg;base64," agar tersisa sandi murninya
      final String pureBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;

      // Dekode sandi menjadi Byte Gambar
      final Uint8List bytes = base64Decode(pureBase64);

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          height: 140,
          width: 100,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      debugPrint("Gagal memuat gambar: $e");
      return Container(
        height: 140,
        width: 100,
        decoration: BoxDecoration(
            color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
        child: const Center(
            child: Text("Gambar\nRusak",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12))),
      );
    }
  }

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
      String jamDiminum = waktuVerifikasi ?? waktu;
      subtitleText = "Diminum pada pukul $jamDiminum";
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

    // Ambil list foto burst (jika ada)
    List<dynamic> prosesMinum = buktiFoto?['proses_minum'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF5),

      // ================= HEADER =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Detail",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // 🔹 DIUBAH: Tambah SingleChildScrollView agar layar bisa di-scroll ke bawah saat foto muncul
      body: SingleChildScrollView(
        child: Padding(
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
                      Text(titleText,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(subtitleText),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                // ================= INFO OBAT =================
                Row(
                  children: [
                    const Icon(Icons.medication, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(namaObat,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(dosis),
                Text(fase),
                const SizedBox(height: 8),
                Text("pukul $waktu",
                    style: const TextStyle(color: Colors.blue)),
                const SizedBox(height: 24),

                // =========================================================
                // 🔹 BAGIAN BARU: HASIL VERIFIKASI AI & BUKTI FOTO vDOT
                // =========================================================
                if (buktiFoto != null || verifikasiAi != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text("Verifikasi Pengawas (vDOT)",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // 1. KOTAK STATUS AI
                  if (verifikasiAi != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16), // Fixed here
                      decoration: BoxDecoration(
                        color: verifikasiAi == 'Valid'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: verifikasiAi == 'Valid'
                                ? Colors.green
                                : Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              verifikasiAi == 'Valid'
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: verifikasiAi == 'Valid'
                                  ? Colors.green
                                  : Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              skorAi != null
                                  ? "Skor Kemiripan Obat: ${(skorAi! * 100).toStringAsFixed(0)}%\nSaran AI: $verifikasiAi"
                                  : "Status AI: $verifikasiAi",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 2. FOTO OBAT & FOTO MANGAP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Obat & Wajah",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          _buildBase64Image(buktiFoto?['obat']),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Mulut Terbuka",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          _buildBase64Image(buktiFoto?['mulut_kosong']),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. FOTO BURST (MENELAN)
                  const Text("Proses Menelan",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  if (prosesMinum.isEmpty)
                    const Text("Tidak ada rekaman burst.",
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: prosesMinum.map((b64) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _buildBase64Image(b64.toString()),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],

                // ================= DROPDOWN CATATAN =================
                const Divider(),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text("Lihat catatan"),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Tidak ada catatan untuk jadwal ini.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
