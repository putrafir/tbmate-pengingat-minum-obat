import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/pages/inputusia.dart';
import 'package:go_router/go_router.dart';


class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  final int minWeight = 37;
  final int maxWeight = 70;
  late int _selectedWeight;
  late ScrollController _scrollController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedWeight = 41;
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
    final int middleIndex = (_scrollController.offset / itemHeight).round();
    final newWeight = minWeight + middleIndex + 2;
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
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black54,
        ),
        child: Text(weight.toString()),
      ),
    );
  }

  Future<void> _saveWeightToFirestore() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'weight': _selectedWeight,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("✅ Berat badan $_selectedWeight kg disimpan")),
          );

         context.go('/set-time');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User belum login")),
        );
      }
    } catch (e) {
      debugPrint("❌ Gagal menyimpan berat badan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    const double headerFraction = 0.4;
    final double headerHeight = screenHeight * headerFraction;
    final itemCount = (maxWeight - minWeight + 1) + 4;

    return Scaffold(
      backgroundColor: kPrimaryGreen,
      body: Column(
        children: [
          // ===== HEADER HIJAU =====
          Container(
            height: headerHeight,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
            decoration: const BoxDecoration(
              color: kPrimaryGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AgeGroupSelectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/icon2.png',
                  height: 220,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Yuk isi berat badanmu, biar TBMATE bisa jadi teman sehat yang pas buatmu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ===== BODY PUTIH =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(32, 25, 32, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Berat badan pasien membantu menentukan program pengobatan TB yang tepat dengan obat FDC (Fixed-Dose Combined)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pilih Berat Badan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== PILIH BERAT =====
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFA6D9E8),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
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
                            itemExtent: 40.0,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index < 2 || index >= itemCount - 2) {
                                return const SizedBox(height: 40);
                              }
                              final weight = minWeight + index - 2;
                              return _buildWeightItem(weight);
                            },
                          ),
                        ),

                        // ===== HIGHLIGHT =====
                        Positioned(
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: kPrimaryGreen,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedWeight.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "kg",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveWeightToFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8ED8F8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Selesai",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
