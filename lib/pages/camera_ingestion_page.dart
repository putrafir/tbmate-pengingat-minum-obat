import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraIngestionPage extends StatefulWidget {
  final DocumentReference jadwalDocRef;
  final String namaObat;

  const CameraIngestionPage({
    super.key,
    required this.jadwalDocRef,
    required this.namaObat,
  });

  @override
  State<CameraIngestionPage> createState() => _CameraIngestionPageState();
}

class _CameraIngestionPageState extends State<CameraIngestionPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _instructionText = "Posisikan wajah dan obat di area garis";

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // Ambil daftar kamera yang tersedia di device
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prioritaskan kamera depan untuk VDOT (Video Directly Observed Therapy)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false, // Matikan audio karena kita cuma butuh visual
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // 🔹 Ini fungsi sementara sebelum dipasang Computer Vision
  Future<void> _onDetectionSuccess() async {
    setState(() {
      _instructionText = "Obat terdeteksi diminum! Memproses...";
    });

    try {
      // Update status ke Firestore
      await widget.jadwalDocRef.update({'status': 'Sudah diminum'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil memverifikasi minum obat!")),
        );
        Navigator.pop(context); // Otomatis kembali ke JadwalPage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update status: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview (Layar Penuh)
          CameraPreview(_cameraController!),

          // 2. Custom Overlay (Membuat sekeliling layar gelap kecuali area target)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Tingkat kegelapan
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                // Panduan Wajah (Kotak Kiri)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 30,
                  child: Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Ini akan tembus pandang karena ColorFiltered
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Panduan Obat (Kotak Kanan)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  right: 40,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape
                          .circle, // Dibuat bulat agar cocok untuk pil/tablet
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Garis Stroke (Border luar agar terlihat jelas oleh user)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 30,
            child: Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 4. Header & Tombol Close
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.flash_off, color: Colors.white),
                Text("Verifikasi ${widget.namaObat}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 5. Instruction Boxes & Tombol Simulasi
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.center_focus_strong,
                          color: Colors.greenAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _instructionText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Tombol ini hanya untuk testing sebelum dipasang ML Kit
                ElevatedButton(
                  onPressed: _onDetectionSuccess,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  child: const Text("Simulasi Sukses Minum",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
