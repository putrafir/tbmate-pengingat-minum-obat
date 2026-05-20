import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditBBPage extends StatefulWidget {
  final String? patientUid;

  const EditBBPage({
    super.key,
    this.patientUid,
  });

  @override
  State<EditBBPage> createState() => _EditBBPageState();
}

class _EditBBPageState extends State<EditBBPage> {
  final int minWeight = 37;
  final int maxWeight = 70;

  late int _selectedWeight;
  late ScrollController _scrollController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedWeight = 41;
    _scrollController = ScrollController();

    _loadWeight();
  }

  Future<void> _loadWeight() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String targetUid = widget.patientUid ?? currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .get();

      if (doc.exists && doc.data()!.containsKey('weight')) {
        _selectedWeight = doc['weight'];
      }

      final initialOffset = (_selectedWeight - minWeight) * 40.0;
      _scrollController = ScrollController(
        initialScrollOffset: initialOffset,
      );
    } catch (e) {
      debugPrint("Error load weight: $e");
    }

    setState(() {
      _isLoading = false;
    });
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

  Future<void> _updateWeight() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      String targetUid = widget.patientUid ?? currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .update({
        'weight': _selectedWeight,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Berat badan berhasil diubah menjadi $_selectedWeight kg",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error update weight: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengubah berat badan"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = (maxWeight - minWeight + 1) + 4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Berat Badan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: const Color(0xFFF9FFF6),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Ubah berat badan terbaru pasien",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== Picker Berat =====
                  Container(
                    height: 220,
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
                              const itemHeight = 40.0;

                              final offset = notification.metrics.pixels;

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
                                return const SizedBox(
                                  height: 40,
                                );
                              }

                              final weight = minWeight + index - 2;

                              return _buildWeightItem(weight);
                            },
                          ),
                        ),

                        // Highlight Tengah
                        Positioned(
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFF388E3C),
                              borderRadius: BorderRadius.circular(12),
                            ),
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

                  const SizedBox(height: 40),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateWeight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF79D5F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
