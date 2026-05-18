import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PatientSetupPage extends StatefulWidget {
  const PatientSetupPage({super.key});

  @override
  State<PatientSetupPage> createState() => _PatientSetupPageState();
}

class _PatientSetupPageState extends State<PatientSetupPage> {
  int currentStep = 0;

  String selectedAgeGroup = "Dewasa";

  int selectedWeight = 41;

  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final FixedExtentScrollController weightController =
      FixedExtentScrollController(initialItem: 31);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F7A2E),
      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Column(
                children: [
                  /// BACK + STEP
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (currentStep == 0) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              currentStep--;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Langkah ${currentStep + 1} dari 3",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// STEP INDICATOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) {
                        final active = index <= currentStep;

                        return Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(
                                        0xFF6EC1E4,
                                      )
                                    : Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (index != 2)
                              Container(
                                width: 45,
                                height: 2,
                                color: active
                                    ? const Color(
                                        0xFF6EC1E4,
                                      )
                                    : Colors.white24,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// MASCOT
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF1F7A2E),
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// TITLE
                  Text(
                    _getTitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// SUBTITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Text(
                      _getSubtitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= CONTENT =================
            // Expanded(
            //   child: Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(24),
            //     decoration: const BoxDecoration(
            //       color: Color(0xFFF5F8F2),
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(40),
            //         topRight: Radius.circular(40),
            //       ),
            //     ),

            //     child: AnimatedSwitcher(
            //       duration: const Duration(milliseconds: 300),
            //        child: SingleChildScrollView(
            //         physics: const BouncingScrollPhysics(),
            //         child: Padding(
            //           padding:const EdgeInsets.only(bottom: 30),
            //           child: _buildStepContent(),
            //           ),
            //        ),
            //     ),
            //   ),
            // ),
            /// ================= CONTENT =================
            Expanded(
                child: Stack(
              children: [
                DraggableScrollableSheet(
                  initialChildSize: 1.0,
                  minChildSize: 1.0,
                  maxChildSize: 1.0,
                  builder: (context, scrollController) {
                    return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F8F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 6,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: _buildStepContent(),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ));
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  /// ================= STEP CONTENT =================

  Widget _buildStepContent() {
    switch (currentStep) {
      /// STEP 1
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
           
            const SizedBox(height: 28),
            _buildAgeCard(
              title: "Anak-anak",
              subtitle: "Usia 0 - 17 tahun",
              selected: selectedAgeGroup == "Anak-anak",
            ),
            const SizedBox(height: 16),
            _buildAgeCard(
              title: "Dewasa",
              subtitle: "Usia 18 tahun ke atas",
              selected: selectedAgeGroup == "Dewasa",
            ),
            const SizedBox(
              height: 40,
            ),
            _buildButton(
              text: "Lanjut",
              onPressed: () {
                setState(() {
                  currentStep++;
                });
              },
            ),
          ],
        );

      /// STEP 2
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           

            const SizedBox(height: 24),

            /// LABEL
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                "Berat Badan Pasien",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// PICKER FIXED
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFF6EC1E4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CupertinoPicker(
                scrollController: weightController,
                itemExtent: 54,
                magnification: 1.15,
                useMagnifier: true,
                squeeze: 1.1,
                selectionOverlay: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7A2E).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedWeight = index + 10;
                  });
                },
                children: List.generate(
                  111,
                  (index) {
                    final weight = index + 10;

                    final isSelected = weight == selectedWeight;

                    return Center(
                      child: Text(
                        "$weight kg",
                        style: TextStyle(
                          fontSize: isSelected ? 34 : 22,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(
                                  0xFF1F7A2E,
                                )
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// CURRENT VALUE
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$selectedWeight kg",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F7A2E),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            _buildButton(
              text: "Lanjut",
              onPressed: () {
                setState(() {
                  currentStep++;
                });
              },
            ),
          ],
        );

      /// STEP 3
      default:
        return Column(
          key: const ValueKey(2),
          children: [
           
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6EC1E4),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EC1E4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(
                        Icons.alarm,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Pilih Waktu Alarm",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            _buildButton(
              text: "Simpan Pasien",
              onPressed: () {
                /// NANTI SIMPAN FIRESTORE
              },
            ),
          ],
        );
    }
  }

  /// ================= WIDGET =================

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6EC1E4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF6EC1E4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCard({
    required String title,
    required String subtitle,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAgeGroup = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF6EC1E4) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(
                title == "Anak-anak" ? Icons.child_care : Icons.person,
                color: const Color(0xFF1F7A2E),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected ? const Color(0xFF6EC1E4) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: Color(0xFF6EC1E4),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (currentStep) {
      case 0:
        return "Setiap usia punya\nkebutuhan berbeda";

      case 1:
        return "Yuk isi\nberat badan pasien";

      default:
        return "Atur jam\npengingat obat";
    }
  }

  String _getSubtitle() {
    switch (currentStep) {
      case 0:
        return "Kelompok usia membantu menentukan program pengobatan yang tepat.";

      case 1:
        return "Berat badan membantu menentukan dosis pengobatan pasien.";

      default:
        return "Alarm akan membantu pasien minum obat tepat waktu.";
    }
  }
}
