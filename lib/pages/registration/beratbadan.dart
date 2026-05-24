import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';

class WeightStep extends StatefulWidget {
  final bool isFromPMO;
  final Function(int) onNext;

  const WeightStep({super.key, this.isFromPMO = false, required this.onNext});

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  final int minWeight = 20;
  final int maxWeight = 150;
  late int _selectedWeight;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedWeight = 50;
    // Mengatur posisi awal scroll sesuai berat badan default
    final initialOffset = (_selectedWeight - minWeight) * 40.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double itemHeight = 40.0;
    // Menghitung index item yang berada di tengah berdasarkan scroll
    final int middleIndex = (_scrollController.offset / itemHeight).round();
    final newWeight = minWeight + middleIndex + 2;

    // Perbarui state hanya jika berat badan berubah
    if (newWeight >= minWeight &&
        newWeight <= maxWeight &&
        newWeight != _selectedWeight) {
      setState(() {
        _selectedWeight = newWeight;
      });
    }
  }

  Widget _buildWeightItem(int weight) {
    final bool isSelected = weight == _selectedWeight;

    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: isSelected ? 24 : 18,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          // Transparan agar teks yang di belakang kotak hijau tidak bertabrakan
          color: isSelected ? Colors.transparent : Colors.black45,
        ),
        child: Text(weight.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = (maxWeight - minWeight + 1) + 4;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==========================================
            // LAYER ATAS: HEADER & ILUSTRASI (FLEKSIBEL)
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/icon2.png',
                      height: 180, // Sedikit disesuaikan agar tidak over-size
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        widget.isFromPMO
                            ? "Masukkan berat badan pasien untuk dosis pengobatan"
                            : "Yuk isi berat badanmu, biar TBMATE bisa jadi teman sehat yang pas!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Sedikit dinaikkan dari 18
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ==========================================
            // LAYER BAWAH: KOTAK PUTIH (PADAT / HUG CONTENT)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(32, 36, 32, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hug content
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.isFromPMO
                        ? "Berat badan membantu menentukan program pengobatan TB (Kombinasi Dosis Tetap)."
                        : "Berat badan membantu TBMate menyesuaikan pemantauan kesehatanmu.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kSubtitleColor,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pilih Berat Badan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================
                  // WIDGET SCROLL BERAT BADAN
                  // ==========================================
                  Container(
                    height: 220, // Diperbesar sedikit agar scroll lebih enak
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFF8FFF3), // Disamakan dengan form sebelumnya
                      borderRadius: BorderRadius.circular(20), // Konsisten 20
                      border: Border.all(
                        color: const Color(0xFFA6D9E8),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // List angka yang bisa di-scroll
                        NotificationListener<ScrollEndNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.axis == Axis.vertical) {
                              const double itemHeight = 40.0;
                              final double offset = notification.metrics.pixels;
                              final int index = (offset / itemHeight).round();
                              final double targetOffset = index * itemHeight;

                              _scrollController.animateTo(
                                targetOffset,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );

                              setState(() {
                                _selectedWeight = minWeight + index + 2;
                              });
                            }
                            return true;
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: itemCount,
                            itemExtent:
                                40.0, // Harus konsisten dengan itemHeight
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              // Item kosong di awal dan akhir agar angka pertama/terakhir bisa ke tengah
                              if (index < 2 || index >= itemCount - 2) {
                                return const SizedBox(height: 40);
                              }
                              final weight = minWeight + index - 2;
                              return _buildWeightItem(weight);
                            },
                          ),
                        ),

                        // Highlight Hijau di tengah (Penunjuk Angka)
                        // IgnorePointer agar tidak mengganggu scroll ListView di bawahnya
                        IgnorePointer(
                          child: Container(
                            height: 60, // Sedikit lebih besar
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedWeight.toString(),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "kg",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==========================================
                  // TOMBOL SELESAI
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => widget.onNext(_selectedWeight),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF75CDE7), // Serasi dengan tombol wizard lain
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Selesai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SafeArea(
                    top: false,
                    child: SizedBox(height: 10),
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
