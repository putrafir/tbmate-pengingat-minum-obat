import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/components/auth-header.dart';

class TimeStep extends StatefulWidget {
  final bool isFromPMO;
  final bool isLoading;
  final Function(String time) onFinish;

  const TimeStep(
      {super.key,
      this.isFromPMO = false,
      required this.isLoading,
      required this.onFinish});

  @override
  State<TimeStep> createState() => _TimeStepState();
}

class _TimeStepState extends State<TimeStep> {
  final TextEditingController _hourController =
      TextEditingController(text: "00");
  final TextEditingController _minuteController =
      TextEditingController(text: "00");
  bool isAm = true;

  void _updateHour() {
    int hour = int.tryParse(_hourController.text) ?? 0;
    if (hour > 12) hour = 12;
    if (hour < 0) hour = 0;
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
      resizeToAvoidBottomInset: true,
      backgroundColor: kPrimaryGreen,
      body: Column(
        children: [
          AuthHeader(
              imagePath: 'assets/tibi/tibi-happy.png',
              title: 'SETEL WAKTU',
              subtitle: widget.isFromPMO
                  ? 'Atur jadwal minum obat pasien.'
                  : 'Atur waktu pengingatmu agar TBMATE bisa bantu kamu minum obat tepat waktu.'),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Setel Waktu Pengingat",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFA6D9E8), width: 2),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeInput(
                                _hourController, "Jam", _updateHour, 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(":",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ),
                            _buildTimeInput(
                                _minuteController, "Menit", _updateMinute, 59),
                            const SizedBox(width: 14),
                            _buildAmPmToggle(isAm),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: widget.isLoading
                            ? null
                            : () {
                                final waktu =
                                    "${_hourController.text}:${_minuteController.text} ${isAm ? "AM" : "PM"}";
                                widget.onFinish(waktu);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8ED8F8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: widget.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Selesai",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                color: Colors.black,
                height: 1.0),
            decoration: const InputDecoration(
                counterText: "", border: InputBorder.none),
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
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmPmToggle(bool isAm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _amPmButton("AM", isAm, true),
        const SizedBox(height: 6),
        _amPmButton("PM", isAm, false),
      ],
    );
  }

  Widget _amPmButton(String label, bool isAmSelected, bool isThisAm) {
    final selected = (isThisAm && isAmSelected) || (!isThisAm && !isAmSelected);

    return GestureDetector(
      onTap: () => _toggleAmPm(isThisAm),
      child: Container(
        width: 40,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: selected ? Colors.blue : Colors.grey.shade400),
          color: selected ? Colors.blue.shade100 : Colors.grey.shade100,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
