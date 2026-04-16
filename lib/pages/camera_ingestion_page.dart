import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'; // 🔹 Komen sementara
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

enum VdotState { searchingPill, pillVerified, drinking, success }

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
  CustomPaint? _customPaint; // 🔹 Tambahan untuk menyimpan visual tracking
  CameraController? _cameraController;
  bool _isProcessing = false;
  VdotState _currentState = VdotState.searchingPill;
  String _instruction = "Tunjukkan Obat TB ke Kamera";

  // late ImageLabeler _pillLabeler; // 🔹 Komen sementara
  late PoseDetector _poseDetector;

  @override
  void initState() {
    super.initState();
    _initDetectors();
    _initCamera();
  }

  void _initDetectors() {
    // 🔹 Komen sementara agar tidak error mencari file tflite
    /*
    _pillLabeler = ImageLabeler(options: LocalLabelerOptions(
      modelPath: 'assets/obat_model.tflite',
      confidenceThreshold: 0.75,
    ));
    */

    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera, 
      ResolutionPreset.medium, 
      enableAudio: false,
      // 🔹 TAMBAHAN PENTING: Paksa kamera ke format yang bisa dibaca ML Kit
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, 
    );
    
    await _cameraController!.initialize();
    
    _cameraController!.startImageStream((image) {
      if (!_isProcessing) _processLogic(image);
    });
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
      if (_currentState == VdotState.searchingPill) {
        // --- TAHAP 1: CARI OBAT ---
        // 🔹 Karena model belum ada, kita matikan logika AI-nya.
        // Transisi ke tahap 2 sekarang dikendalikan oleh Tombol "Lewati" di layar.
      } 
      else if (_currentState == VdotState.pillVerified || _currentState == VdotState.drinking) {
        // --- TAHAP 2: CEK GERAKAN MINUM ---
        final poses = await _poseDetector.processImage(inputImage);
        
        debugPrint("🔍 Jumlah pose terdeteksi: ${poses.length}");

        if (poses.isNotEmpty) {
          // 🔹 MENGGAMBAR TRACKING KE LAYAR
          final painter = PosePainter(
            poses,
            inputImage.metadata!.size,
            inputImage.metadata!.rotation,
            _cameraController!.description.lensDirection,
          );
          _customPaint = CustomPaint(painter: painter);

          if (_isHandAtMouth(poses.first)) {
            setState(() {
              _currentState = VdotState.success;
              _instruction = "Berhasil! Data sedang disimpan...";
            });
            _saveToDatabase();
          } else {
            // Update state agar CustomPaint tergambar meskipun belum sukses
            if (mounted) setState(() {}); 
          }
        } else {
          // Kalau tidak ada pose terdeteksi, hapus tracking
          _customPaint = null;
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  bool _isHandAtMouth(Pose pose) {
    final mouth = pose.landmarks[PoseLandmarkType.leftMouth];
    final hand = pose.landmarks[PoseLandmarkType.rightWrist]; 
    
    if (mouth != null && hand != null) {
      final distance = math.sqrt(math.pow(mouth.x - hand.x, 2) + math.pow(mouth.y - hand.y, 2));
      return distance < 100; // Ambang batas jarak (bisa kamu ubah jika perlu)
    }
    return false;
  }

  void _saveToDatabase() {
    _cameraController?.stopImageStream();
    // TODO: Update Firestore document status ke "Selesai/Diminum"
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  InputImage? _convertToInputImage(CameraImage image) {
    if (_cameraController == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationValue.fromRawValue(
        _cameraController!.description.sensorOrientation) ?? InputImageRotation.rotation0deg;
    
    // 🔹 TAMBAHAN PENTING: Kunci format sesuai platform agar ML Kit tidak bingung
    final inputImageFormat = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    final inputImageData = InputImageMetadata(
      size: imageSize, 
      rotation: imageRotation, 
      format: inputImageFormat, 
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    // 🔹 Ambil resolusi asli kamera. Dibalik (height jadi width) karena posisi Portrait
    final previewSize = _cameraController!.value.previewSize!;
    final cameraWidth = previewSize.height;
    final cameraHeight = previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 TAMPILAN KAMERA & TRACKING ANTI-LONJONG
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover, // Membuat full-screen tanpa melar
              child: SizedBox(
                width: cameraWidth,
                height: cameraHeight,
                child: Stack(
                  children: [
                    CameraPreview(_cameraController!),
                    if (_customPaint != null)
                      Positioned.fill(child: _customPaint!),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 HEADER
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
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // 🔹 TOMBOL BYPASS (Hanya muncul saat tahap mencari obat)
          if (_currentState == VdotState.searchingPill)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(15)),
                onPressed: () {
                  setState(() {
                    // 🔹 Memicu State berubah, TRACKING AKAN MULAI MUNCUL
                    _currentState = VdotState.pillVerified;
                    _instruction = "SIMULASI: Obat Terdeteksi! Silakan Diminum";
                  });
                },
                child: const Text("Lewati Deteksi Obat (Test Mode)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          // 🔹 KOTAK INSTRUKSI
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                  color: _currentState == VdotState.success
                      ? Colors.green.shade800
                      : Colors.black87,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                _instruction,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }



}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  PosePainter(this.poses, this.imageSize, this.rotation, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    // 🔹 Kuas untuk Kotak Wajah
    final faceBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.yellowAccent
      ..strokeWidth = 3.0;

    // 🔹 Kuas untuk Kerangka Lengan & Tangan
    final skeletonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.cyanAccent
      ..strokeWidth = 4.0
      ..strokeJoin = StrokeJoin.round;

    // 🔹 Kuas untuk Titik Sendi (Opsional, biar lebih keren)
    final jointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.redAccent;

    for (final pose in poses) {
      _drawFaceBox(canvas, size, pose, faceBoxPaint);
      _drawArmSkeleton(canvas, size, pose, skeletonPaint, jointPaint);
    }
  }

  // --- FUNGSI MENGGAMBAR KOTAK WAJAH ---
  void _drawFaceBox(Canvas canvas, Size size, Pose pose, Paint paint) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    bool faceFound = false;

    // Titik 0 sampai 10 di ML Kit adalah area wajah (Hidung, Mata, Telinga, Mulut)
    final faceLandmarkTypes = [
      PoseLandmarkType.nose, PoseLandmarkType.leftEye, PoseLandmarkType.rightEye,
      PoseLandmarkType.leftEar, PoseLandmarkType.rightEar,
      PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth,
    ];

    for (var type in faceLandmarkTypes) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        faceFound = true;
        final double x = _translateX(landmark.x, size, imageSize, rotation, cameraLensDirection);
        final double y = _translateY(landmark.y, size, imageSize, rotation);

        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    if (faceFound) {
      // Tambahkan padding agar kotak lebih besar dari wajah asli
      const double padding = 25.0;
      final Rect faceRect = Rect.fromLTRB(
        minX - padding, minY - (padding * 1.5), // Atas dibuat lebih tinggi untuk jidat
        maxX + padding, maxY + padding
      );
      
      // Gambar kotak dengan sudut melengkung (rounded rectangle)
      canvas.drawRRect(RRect.fromRectAndRadius(faceRect, const Radius.circular(12)), paint);
    }
  }

  // --- FUNGSI MENGGAMBAR KERANGKA TANGAN ---
  void _drawArmSkeleton(Canvas canvas, Size size, Pose pose, Paint linePaint, Paint jointPaint) {
    void drawBone(PoseLandmarkType type1, PoseLandmarkType type2) {
      final joint1 = pose.landmarks[type1];
      final joint2 = pose.landmarks[type2];
      if (joint1 != null && joint2 != null && joint1.likelihood > 0.5 && joint2.likelihood > 0.5) {
        final x1 = _translateX(joint1.x, size, imageSize, rotation, cameraLensDirection);
        final y1 = _translateY(joint1.y, size, imageSize, rotation);
        final x2 = _translateX(joint2.x, size, imageSize, rotation, cameraLensDirection);
        final y2 = _translateY(joint2.y, size, imageSize, rotation);
        
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        canvas.drawCircle(Offset(x1, y1), 5, jointPaint); // Gambar sendi 1
        canvas.drawCircle(Offset(x2, y2), 5, jointPaint); // Gambar sendi 2
      }
    }

    // Lengan Kiri (Bahu -> Siku -> Pergelangan)
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    // Jari Tangan Kiri (Pergelangan -> Jempol, Telunjuk, Kelingking)
    drawBone(PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb);
    drawBone(PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex);
    drawBone(PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky);

    // Lengan Kanan (Bahu -> Siku -> Pergelangan)
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    // Jari Tangan Kanan (Pergelangan -> Jempol, Telunjuk, Kelingking)
    drawBone(PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb);
    drawBone(PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex);
    drawBone(PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

  double _translateX(double x, Size canvasSize, Size imageSize, InputImageRotation rotation, CameraLensDirection cameraLensDirection) {
    double scaleX;
    
    // 1. Sesuaikan skala karena frame kamera Android aslinya Landscape (tertukar)
    if (Platform.isAndroid && (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg)) {
      scaleX = canvasSize.width / imageSize.height;
    } else {
      scaleX = canvasSize.width / imageSize.width;
    }

    double scaledX = x * scaleX;

    // 2. FIX MIRRORING: Kalau kamera depan, balikkan sumbu X (kiri jadi kanan)
    if (cameraLensDirection == CameraLensDirection.front) {
      return canvasSize.width - scaledX; 
    }
    
    return scaledX;
  }

  // Helper untuk menyesuaikan skala Y (Diperbaiki untuk Rotasi)
  double _translateY(double y, Size canvasSize, Size imageSize, InputImageRotation rotation) {
    double scaleY;
    
    // 1. Sesuaikan skala karena frame kamera Android aslinya Landscape (tertukar)
    if (Platform.isAndroid && (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg)) {
      scaleY = canvasSize.height / imageSize.width;
    } else {
      scaleY = canvasSize.height / imageSize.height;
    }

    return y * scaleY;
  }
}