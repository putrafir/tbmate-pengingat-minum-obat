import 'package:flutter/material.dart';

class NameStep extends StatefulWidget {
  final Function(String fullName, String nickName) onNext;
  const NameStep({super.key, required this.onNext});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  OverlayEntry? _overlayEntry;

  // --- Overlay Error ---
  void _showError(String message) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              border: Border.all(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), () => _removeOverlay());
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // --- Input Validation ---
  void _validateAndSubmit() {
    final fullName = fullNameController.text.trim();
    final nickName = nickNameController.text.trim();
    final nameRegex = RegExp(r'^[A-Za-zÀ-ÿ\s]+$');

    if (fullName.isEmpty || nickName.isEmpty) {
      _showError("Masukkan nama anda terlebih dahulu");
      return;
    } else if (!nameRegex.hasMatch(fullName) || !nameRegex.hasMatch(nickName)) {
      _showError("Nama hanya boleh berisi huruf dan spasi");
      return;
    }

    widget.onNext(fullName, nickName);
  }

  // --- Input Field ---
  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.lightBlueAccent.shade100),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    fullNameController.dispose();
    nickNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const headerFraction = 0.40;
    final headerHeight = screenHeight * headerFraction;

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER ---
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 60, 32, 0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/Group 11.png', width: 130),
                      const SizedBox(height: 30),
                      const Text(
                        "Biar lebih akrab, sebutin\nnama kamu ya!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // --- BODY FORM ---
                Container(
                  width: double.infinity,
                  height: screenHeight * (1 - headerFraction) + 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FFF4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        hintText: "Nama Panjang",
                        controller: fullNameController,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        hintText: "Nama Panggilan",
                        controller: nickNameController,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tenang, kamu bisa mengubahnya kapan saja!",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _validateAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "Lanjut",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
