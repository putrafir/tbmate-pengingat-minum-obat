import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';

class TimeStep extends StatefulWidget {
  final bool isFromPMO;
  final bool isLoading;
  final Function(String time) onFinish;

  const TimeStep({
    super.key,
    this.isFromPMO = false,
    required this.isLoading,
    required this.onFinish,
  });

  @override
  State<TimeStep> createState() => _TimeStepState();
}

class _TimeStepState extends State<TimeStep> {
  // Secara default setel ke 08:00 AM (lebih masuk akal daripada 00:00 untuk format 12 jam)
  final TextEditingController _hourController =
      TextEditingController(text: "08");
  final TextEditingController _minuteController =
      TextEditingController(text: "00");
  bool isAm = true;

  void _updateHour() {
    int hour = int.tryParse(_hourController.text) ?? 0;
    if (hour > 12) hour = 12;
    if (hour < 0)
      hour = 0; // Sebenarnya format 12 jam minimal 1, tapi kita biarkan aman
    setState(() {
      _hourController.text = hour.toString().padLeft(2, '0');
    });
  }

  void _updateMinute() {
    int minute = int.tryParse(_minuteController.text) ?? 0;
    if (minute > 59) minute = 59;
    if (minute < 0) minute = 0;
    setState(() {
      _minuteController.text = minute.toString().padLeft(2, '0');
    });
  }

  void _toggleAmPm(bool am) {
    setState(() {
      isAm = am;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryGreen,
      // 🔹 STACK: Memisahkan Header (Belakang) dan Form (Depan)
      body: Stack(
        children: [
          // ==========================================
          // LAYER 1: MASKOT & TEKS (FIXED DI ATAS)
          // ==========================================
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: AuthHeader(
                  imagePath: 'assets/tibi/tibi-happy.png',
                  title: 'SETEL WAKTU',
                  subtitle: widget.isFromPMO
                      ? 'Atur jadwal minum obat pasien.'
                      : 'Atur waktu pengingatmu agar TBMate bisa bantu kamu minum obat tepat waktu.',
                ),
              ),
            ),
          ),

          // ==========================================
          // LAYER 2: KOTAK PUTIH FORM (SLIDING)
          // ==========================================
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FFF4), // Diseragamkan warnanya
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), // Seragam 40
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
                  mainAxisSize: MainAxisSize.min, // 🔹 KUNCI ANTI-OVERFLOW
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Setel Waktu Pengingat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- KOTAK INPUT WAKTU ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            20), // Seragam dengan form lain
                        border: Border.all(
                          color: const Color(0xFFA6D9E8),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeInput(
                                _hourController, "Jam", _updateHour, 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            _buildTimeInput(
                                _minuteController, "Menit", _updateMinute, 59),
                            const SizedBox(
                                width: 24), // Jarak ke AM/PM diperlebar sedikit
                            _buildAmPmToggle(isAm),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- TOMBOL SELESAI ---
                    SizedBox(
                      width: double.infinity,
                      height: 52, // Disamakan tingginya
                      child: ElevatedButton(
                        onPressed: widget.isLoading
                            ? null
                            : () {
                                final waktu =
                                    "${_hourController.text}:${_minuteController.text} ${isAm ? "AM" : "PM"}";
                                widget.onFinish(waktu);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF75CDE7), // Warna seragam
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Selesai",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    // Jarak aman bawah
                    const SafeArea(
                      top: false,
                      child: SizedBox(height: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label,
      VoidCallback onEditingComplete, int maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.0,
            ),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.length == 2) {
                int val = int.tryParse(value) ?? 0;
                if (val > maxValue) {
                  val = maxValue;
                  controller.text = val.toString().padLeft(2, '0');
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length));
                }
              }
            },
            onEditingComplete: () {
              if (controller.text.isEmpty) controller.text = "00";
              int val = int.tryParse(controller.text) ?? 0;
              if (val > maxValue) val = maxValue;
              controller.text = val.toString().padLeft(2, '0');
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
              onEditingComplete();
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmPmToggle(bool isAm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _amPmButton("AM", isAm, true),
        const SizedBox(height: 8),
        _amPmButton("PM", isAm, false),
      ],
    );
  }

  Widget _amPmButton(String label, bool isAmSelected, bool isThisAm) {
    final selected = (isThisAm && isAmSelected) || (!isThisAm && !isAmSelected);

    return GestureDetector(
      onTap: () => _toggleAmPm(isThisAm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // 🔹 WARNA DIUBAH: Mengikuti identitas hijau TBMate, bukan lagi biru bawaan
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: 1.5,
          ),
          color: selected
              ? const Color(0xFF2E7D32).withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
