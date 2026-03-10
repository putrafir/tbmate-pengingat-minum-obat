import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  int selectedTab = 0; // 0 = Diminum, 1 = Dilewati
  bool showCatatan = true;
  bool showCatatan1Sept = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),
      body: Column(
        children: [
          // 🔹 Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SafeArea(
              bottom: false,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Riwayat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Tab Diminum / Dilewati
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  _buildTabItem("2", "Diminum", 0, Colors.green),
                  _buildTabItem("1", "Dilewati", 1, Colors.green),
                ],
              ),
            ),
          ),

          // 🔹 Konten berubah sesuai tab
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: selectedTab == 0
                  ? _buildDiminumContent()
                  : _buildDilewatiContent(),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Fungsi Tab
  Expanded _buildTabItem(String count, String title, int index, Color color) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Konten untuk tab "Diminum"
  Widget _buildDiminumContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("2 September",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildObatCard(
            namaObat: "4 KDT RHZE",
            dosis: "Tablet, 55 mg/kg",
            jadwal: "Setiap hari, Setelah makan",
            waktuMinum: "2 tablet pukul 08:00 diminum pukul 12.00",
            status: "Terlambat",
            warnaStatus: Colors.green,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                showCatatan = !showCatatan;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showCatatan ? "Sembunyikan catatan" : "Lihat catatan",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Icon(
                  showCatatan
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                )
              ],
            ),
          ),
          if (showCatatan) ...[
            const SizedBox(height: 8),
            _buildCatatan("Tidak membawa obat", "08.05"),
            _buildCatatan("Mual, perut terasa tidak nyaman", "10.00"),
          ],
        ],
      ),
    );
  }

  // 🔹 Konten untuk tab "Dilewati"
  Widget _buildDilewatiContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("1 September",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildObatCard(
            namaObat: "4 KDT RHZE",
            dosis: "Tablet, 55 mg/kg",
            jadwal: "Setiap hari, Setelah makan",
            waktuMinum: "2 tablet pukul 08:00 (tidak diminum)",
            status: "Dilewati",
            warnaStatus: Colors.red,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                showCatatan1Sept = !showCatatan1Sept;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showCatatan1Sept ? "Sembunyikan catatan" : "Lihat catatan",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Icon(
                  showCatatan1Sept
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                )
              ],
            ),
          ),
          if (showCatatan1Sept)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FBF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Pasien lupa minum obat karena sedang keluar rumah.",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Kartu obat
  Widget _buildObatCard({
    required String namaObat,
    required String dosis,
    required String jadwal,
    required String waktuMinum,
    required String status,
    required Color warnaStatus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIcons.pill(PhosphorIconsStyle.fill),
                color: Colors.black),
            const SizedBox(width: 8),
            Text(
              namaObat,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: warnaStatus.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: warnaStatus, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(dosis),
        Text(jadwal),
        Text(
          waktuMinum,
          style: const TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  // 🔹 Catatan
  Widget _buildCatatan(String isi, String waktu) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isi),
          Text(
            waktu,
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
