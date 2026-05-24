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

  // --- Overlay Error (Tetap sama, ini sudah bagus!) ---
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
    Future.delayed(const Duration(seconds: 3), () => _removeOverlay());
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
      height: 52, // Dibuat sedikit lebih lega
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16), // Disesuaikan agar serasi dengan tombol
        border: Border.all(
            color: const Color(0xFFA6D9E8), width: 1.5), // Border biru lembut
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
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
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
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
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
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/Group 11.png', width: 140),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "Biar lebih akrab, sebutin\nnama kamu ya!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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
                  color:
                      Color(0xFFF8FFF4), // Warna putih kehijauan khas desainmu
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
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                child: Column(
                  // 🔹 Memaksa tinggi kotak putih hanya sebatas isi kontennya!
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      hintText: "Contoh: Ahmad Putra",
                      controller: fullNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: "Contoh: Putra",
                      controller: nickNameController,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Tenang, kamu bisa mengubahnya kapan saja!",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    // 🔹 PENGGANTI SPACER: Karena mainAxisSize.min, Spacer dilarang.
                    // Gunakan SizedBox untuk memberi jarak tetap sebelum tombol.
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF75CDE7), // Disamakan dengan tombol halaman Role
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Lanjutkan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // SafeArea bawah untuk HP modern
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
}
