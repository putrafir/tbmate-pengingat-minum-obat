import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';

enum VdotState { phase1Obat, phase2Minum, phase3Mangap, uploading, success }

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
  late FaceDetector _faceDetector;

  bool _isProcessing = false;
  bool _isFaceDetected = false;

  VdotState _currentState = VdotState.phase1Obat;
  String _instruction = "Paskan wajah di area oval\ndan tunjukkan obat Anda";

  // 🔹 Tempat Menyimpan 3 Tahap Foto
  XFile? _fotoObat;
  final List<XFile> _fotoMinumBurst = [];
  XFile? _fotoMulutKosong;

  // Skor Kemiripan Obat (Placeholder untuk AI TFLite nanti)
  double _pillConfidenceScore = 0.0;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium, // 🔹 Wajib Medium Biar Hemat Kuota & Storage
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();
    _startAiStream();
  }

  void _startAiStream() {
    if (_cameraController != null &&
        !_cameraController!.value.isStreamingImages) {
      _cameraController!.startImageStream((image) {
        if (!_isProcessing) _processLogic(image);
      });
    }
    if (mounted) setState(() {});
  }

  Future<void> _processLogic(CameraImage image) async {
    _isProcessing = true;
    final inputImage = _convertToInputImage(image);

    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      bool faceFound = faces.isNotEmpty;

      if (mounted && _isFaceDetected != faceFound) {
        setState(() => _isFaceDetected = faceFound);
      }

      // 🔹 Logika Auto-Snap Fase 3 (Mangap)
      if (faceFound && _currentState == VdotState.phase3Mangap) {
        if (_isMouthOpen(faces.first)) {
          await _takeFinalPhoto();
        }
      }

      // Simulasi AI mendeteksi kemiripan obat
      if (_currentState == VdotState.phase1Obat && faceFound) {
        _pillConfidenceScore = 0.85; // Simulasi: AI yakin 85% ini obat TB
      }
    } catch (e) {
      debugPrint("Error AI: $e");
    } finally {
      _isProcessing = false;
    }
  }

  bool _isMouthOpen(Face face) {
    final upperLipBottom =
        face.contours[FaceContourType.upperLipBottom]?.points;
    final lowerLipTop = face.contours[FaceContourType.lowerLipTop]?.points;

    if (upperLipBottom != null &&
        lowerLipTop != null &&
        upperLipBottom.isNotEmpty &&
        lowerLipTop.isNotEmpty) {
      int midIndexUpper = upperLipBottom.length ~/ 2;
      int midIndexLower = lowerLipTop.length ~/ 2;

      double distance =
          (lowerLipTop[midIndexLower].y - upperLipBottom[midIndexUpper].y)
              .abs()
              .toDouble();
      return distance > 15.0; // Ambang batas mulut terbuka (Bisa di-tweak)
    }
    return false;
  }

  // ==========================================
  // --- FUNGSI JEPRET KAMERA (3 TAHAP) ---
  // ==========================================

  Future<void> _takeFotoObat() async {
    try {
      await _cameraController?.stopImageStream();
      _fotoObat = await _cameraController?.takePicture();

      setState(() {
        _currentState = VdotState.phase2Minum;
        _instruction = "Silakan telan obat Anda.\n(Sistem merekam otomatis)";
      });

      _startAiStream();
    } catch (e) {
      debugPrint("Gagal foto obat: $e");
    }
  }

  Future<void> _startBurstMode() async {
    try {
      await _cameraController?.stopImageStream();

      // Jepret 3 kali dengan jeda cepat
      for (int i = 0; i < 3; i++) {
        XFile? pic = await _cameraController?.takePicture();
        if (pic != null) _fotoMinumBurst.add(pic);
        await Future.delayed(const Duration(milliseconds: 600));
      }

      setState(() {
        _currentState = VdotState.phase3Mangap;
        _instruction =
            "Buka mulut lebar-lebar (Katakan 'AAA')\nuntuk bukti obat tertelan.";
      });

      _startAiStream();
    } catch (e) {
      debugPrint("Gagal burst mode: $e");
    }
  }

  Future<void> _takeFinalPhoto() async {
    try {
      await _cameraController?.stopImageStream();
      _fotoMulutKosong = await _cameraController?.takePicture();

      setState(() {
        _currentState = VdotState.uploading;
        _instruction = "Selesai! Mengunggah data ke Puskesmas...";
      });

      await _uploadToPuskesmas();
    } catch (e) {
      debugPrint("Gagal foto mangap: $e");
    }
  }

  // ==========================================
  // --- FUNGSI UPLOAD KE FIREBASE ---
  // ==========================================
  Future<void> _uploadToPuskesmas() async {
    try {
      setState(() {
        _currentState = VdotState.uploading;
        _instruction = "Menyandi gambar & Mengirim ke Database...";
      });

      // 1. Ubah Foto Obat jadi Base64 (Teks)
      String base64Obat = "";
      if (_fotoObat != null) {
        base64Obat = await _imageToBase64(_fotoObat!);
      }

      // 2. Ubah Foto Burst Minum jadi List Base64
      List<String> base64MinumBurst = [];
      for (XFile pic in _fotoMinumBurst) {
        String b64 = await _imageToBase64(pic);
        base64MinumBurst.add(b64);
      }

      // 3. Ubah Foto Mulut Kosong jadi Base64
      String base64Mulut = "";
      if (_fotoMulutKosong != null) {
        base64Mulut = await _imageToBase64(_fotoMulutKosong!);
      }

      // 4. LANGSUNG SIMPAN KE FIRESTORE (Sebagai Teks Panjang)
      await widget.jadwalDocRef.update({
        'status': 'Sudah diminum',
        'waktu_verifikasi': FieldValue.serverTimestamp(),
        'bukti_foto': {
          'obat': base64Obat, // 👈 Disimpan sebagai teks Base64
          'proses_minum': base64MinumBurst, // 👈 List teks Base64
          'mulut_kosong': base64Mulut, // 👈 Teks Base64
        },
        'ai_confidence_score': _pillConfidenceScore,
        'verifikasi_ai': _pillConfidenceScore > 0.7 ? 'Valid' : 'Butuh Review',
      });

      setState(() => _currentState = VdotState.success);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Berhasil! Data terkirim tanpa Storage.",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Gagal Upload Base64: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal mengirim data: $e")),
        );
        setState(() => _currentState = VdotState.phase3Mangap);
      }
    }
  }

  // 🔹 FUNGSI AJAIB: Mengubah File XFile menjadi Teks Base64
  Future<String> _imageToBase64(XFile file) async {
    try {
      final bytes = await File(file.path).readAsBytes();
      String base64String = base64Encode(bytes);
      // Tambahkan header data URI agar nanti gampang ditampilkan di UI (Image.memory)
      return "data:image/jpeg;base64,$base64String";
    } catch (e) {
      debugPrint("Error encoding image: $e");
      return "";
    }
  }

  InputImage? _convertToInputImage(CameraImage image) {
    if (_cameraController == null) return null;
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) allBytes.putUint8List(plane.bytes);
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationValue.fromRawValue(
            _cameraController!.description.sensorOrientation) ??
        InputImageRotation.rotation0deg;
    final inputImageFormat =
        Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;
    return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
            size: imageSize,
            rotation: imageRotation,
            format: inputImageFormat,
            bytesPerRow: image.planes[0].bytesPerRow));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    final previewSize = _cameraController!.value.previewSize!;
    final cameraWidth = previewSize.height;
    final cameraHeight = previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. KAMERA PREVIEW
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: cameraWidth,
                height: cameraHeight,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          // 2. OVERLAY KYC STYLE (Hanya muncul di Fase 1)
          if (_currentState == VdotState.phase1Obat)
            Positioned.fill(child: CustomPaint(painter: KycOverlayPainter())),

          // 3. EFEK GELAP SAAT UPLOAD
          if (_currentState == VdotState.uploading ||
              _currentState == VdotState.success)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              ),
            ),

          // 4. HEADER PERINGATAN WAJAH HILANG
          if (!_isFaceDetected &&
              _currentState != VdotState.uploading &&
              _currentState != VdotState.success)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("⚠️ Wajah tidak terdeteksi!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          // 5. KOTAK INSTRUKSI
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: _currentState == VdotState.uploading
                      ? Colors.green.shade800
                      : Colors.black54,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(_instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),

          // 6. TOMBOL KENDALI
          Positioned(
              bottom: 50, left: 20, right: 20, child: _buildActionButtons()),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentState == VdotState.phase1Obat) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: _isFaceDetected ? Colors.green : Colors.grey,
            padding: const EdgeInsets.all(15)),
        onPressed: _isFaceDetected ? _takeFotoObat : null,
        child: const Text("Ambil Foto Obat",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );
    } else if (_currentState == VdotState.phase2Minum) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
        onPressed: _startBurstMode,
        child: const Text("Saya Mulai Menelan",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }
}

// 🔹 PELUKIS BINGKAI KYC
class KycOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final faceRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.4),
        width: size.width * 0.65,
        height: size.height * 0.4);
    final pillRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: 120,
        height: 80);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addOval(faceRect)
      ..addRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(12)));
    final finalPath =
        Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    canvas.drawPath(finalPath, Paint()..color = Colors.black.withOpacity(0.7));

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(faceRect, borderPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(12)),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
