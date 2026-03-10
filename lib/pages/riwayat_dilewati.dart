import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RiwayatDilewatiPage extends StatefulWidget {
  const RiwayatDilewatiPage({Key? key}) : super(key: key);

  @override
  State<RiwayatDilewatiPage> createState() => _RiwayatDilewatiPageState();
}

class _RiwayatDilewatiPageState extends State<RiwayatDilewatiPage> {
  bool showCatatan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak ringkasan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Diminum
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            '2',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Diminum',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dilewati
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF8E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            '1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Dilewati',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tanggal
            const Text(
              '3 September',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            // Kartu obat
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.pill(PhosphorIconsStyle.fill),
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '4 KDT RHZE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tablet, 55 mg/kg\nSetiap hari, Setelah makan',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2 tablet pukul 08:00',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),

                  // Tombol lihat / sembunyikan catatan
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
                          showCatatan ? 'Sembunyikan catatan' : 'Lihat catatan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Icon(
                          showCatatan
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),

                  // Daftar catatan
                  if (showCatatan) ...[
                    const SizedBox(height: 8),
                    _buildCatatan("Tidak membawa obat", "08.05"),
                    _buildCatatan("Mual, perut terasa tidak nyaman", "10.00"),
                    _buildCatatan("Tidak membawa obat", "12.01"),
                    _buildCatatan("Mual, perut terasa tidak nyaman", "14.00"),
                    _buildCatatan("Tidak membawa obat", "16.05"),
                    _buildCatatan("Mual, perut terasa tidak nyaman", "18.00"),
                    _buildCatatan("Tidak membawa obat", "20.05"),
                    _buildCatatan("Mual, perut terasa tidak nyaman", "22.00"),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatan(String isi, String waktu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isi,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Text(
            waktu,
            style: const TextStyle(fontSize: 13, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
