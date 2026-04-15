import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';

// 🔹 Alur State Sesuai Kesepakatan Kita
enum VdotState { searchingFace, showingPill, drinking, checkingMouth, success }

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
  CustomPaint? _customPaint;
  bool _isProcessing = false;

  VdotState _currentState = VdotState.searchingFace;
  String _instruction = "Posisikan wajah Anda di kamera";
  bool _isFaceDetected = false;
  int _countdown = 3;
  Timer? _timer;

  // 🔹 "Otak" AI Baru: Face Detector dengan fitur Contours (untuk baca bibir)
  late FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Face Detector (Wajib nyalakan Contours untuk ngecek mulut terbuka)
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableTracking: true, // Biar AI tahu itu wajah yang sama
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
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
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
      final faces = await _faceDetector.processImage(inputImage);

      // 1. Cek Apakah Wajah Ada di Kamera
      bool faceFound = faces.isNotEmpty;
      if (mounted && _isFaceDetected != faceFound) {
        setState(() {
          _isFaceDetected = faceFound;
        });
      }

      if (faceFound) {
        final face = faces.first; // Asumsi hanya ada 1 wajah (pasien)

        // 🔹 GAMBAR KOTAK WAJAH & BIBIR (Visual UI Keren)
        final painter = FacePainter(
          face,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraController!.description.lensDirection,
        );
        _customPaint = CustomPaint(painter: painter);

        // 🔹 LOGIKA STATE MACHINE
        if (_currentState == VdotState.checkingMouth) {
          if (_isMouthOpen(face)) {
            setState(() {
              _currentState = VdotState.success;
              _instruction = "Verifikasi Berhasil! Menyimpan data...";
            });
            _saveToDatabase();
          }
        }
      } else {
        // Hapus kotak kalau wajah hilang
        _customPaint = null;

        // Peringatan PENTING: Wajah Hilang!
        if (_currentState != VdotState.searchingFace &&
            _currentState != VdotState.success) {
          if (mounted) {
            // Opsional: Kamu bisa nambahin logika pause timer di sini
            debugPrint("PERINGATAN: Wajah Hilang!");
          }
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error Face Detection: $e");
    } finally {
      _isProcessing = false;
    }
  }

  // 🔹 INI KUNCI UTAMA (Magic-nya AI untuk ngecek mulut terbuka)
  bool _isMouthOpen(Face face) {
    // Ambil titik bibir atas bagian bawah, dan bibir bawah bagian atas (celah mulut)
    final upperLipBottom =
        face.contours[FaceContourType.upperLipBottom]?.points;
    final lowerLipTop = face.contours[FaceContourType.lowerLipTop]?.points;

    if (upperLipBottom != null &&
        lowerLipTop != null &&
        upperLipBottom.isNotEmpty &&
        lowerLipTop.isNotEmpty) {
      // Ambil titik tengah bibir (index ke-4 atau ke-5 biasanya pas di tengah)
      int midIndexUpper = upperLipBottom.length ~/ 2;
      int midIndexLower = lowerLipTop.length ~/ 2;

      double yUpper = upperLipBottom[midIndexUpper].y.toDouble();
      double yLower = lowerLipTop[midIndexLower].y.toDouble();

      // Hitung jarak vertikal celah bibir
      double distance = (yLower - yUpper).abs();

      // Jika jaraknya lebih dari 15 pixel (bisa disesuaikan), berarti mulut terbuka (bilang 'AAA')
      return distance > 15.0;
    }
    return false;
  }

  // --- LOGIKA TOMBOL & TRANSI ---

  void _startShowingPill() {
    setState(() {
      _currentState = VdotState.showingPill;
      _instruction = "Tunjukkan obat ke kamera ($_countdown)";
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown > 0) {
          _instruction = "Tunjukkan obat ke kamera ($_countdown)";
        } else {
          timer.cancel();
          _startDrinking();
        }
      });
    });
  }

  void _startDrinking() {
    setState(() {
      _currentState = VdotState.drinking;
      _instruction = "Silakan minum obat Anda sekarang";
    });
  }

  void _startCheckingMouth() {
    setState(() {
      _currentState = VdotState.checkingMouth;
      _instruction = "Buka mulut Anda (Bilang 'AAA')";
    });
  }

  Future<void> _saveToDatabase() async {
    _cameraController?.stopImageStream();

    // 🔹 Jepret Foto Bukti (Snapshot AI)
    XFile? picture;
    try {
      picture = await _cameraController?.takePicture();
      debugPrint("📸 Foto bukti tersimpan di: ${picture?.path}");
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
    }

    // TODO: Upload `picture` ke Firebase Storage, lalu update Firestore jadwalDocRef

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // (Fungsi _convertToInputImage SAMA PERSIS seperti kodemu sebelumnya)
  InputImage? _convertToInputImage(CameraImage image) {
    if (_cameraController == null) return null;
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationValue.fromRawValue(
            _cameraController!.description.sensorOrientation) ??
        InputImageRotation.rotation0deg;
    final inputImageFormat =
        Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;
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
    _timer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()));
    }

    final previewSize = _cameraController!.value.previewSize!;
    final cameraWidth = previewSize.height;
    final cameraHeight = previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. KAMERA & TRACKING Wajah
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
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

          // 2. HEADER Teks Merah kalau Wajah Hilang
          if (!_isFaceDetected && _currentState != VdotState.success)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: const Text("⚠️ WAJAH TIDAK TERDETEKSI!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          // 3. TOMBOL KENDALI ALUR
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: _buildActionButtons(),
          ),

          // 4. KOTAK INSTRUKSI
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: _currentState == VdotState.success
                      ? Colors.green.shade800
                      : Colors.black87,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                _instruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 🔹 Ganti Tombol sesuai State
  Widget _buildActionButtons() {
    if (_currentState == VdotState.searchingFace) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: _isFaceDetected ? Colors.blue : Colors.grey,
            padding: const EdgeInsets.all(15)),
        onPressed: _isFaceDetected
            ? _startShowingPill
            : null, // Cuma bisa diklik kalau wajah kelihatan
        child: const Text("Mulai Minum Obat",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    } else if (_currentState == VdotState.drinking) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
        onPressed: _startCheckingMouth,
        child: const Text("Saya Sudah Menelan Obat",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      );
    }
    return const SizedBox.shrink(); // Sembunyikan tombol di state lain
  }
}

// 🔹 PAINTER UNTUK MENGGAMBAR KOTAK WAJAH & TITIK BIBIR
class FacePainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  FacePainter(
      this.face, this.imageSize, this.rotation, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBox = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;
    final paintLip = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.redAccent;

    // 1. Gambar Kotak Wajah
    final boundingBox = face.boundingBox;
    final left = _translateX(
        boundingBox.left, size, imageSize, rotation, cameraLensDirection);
    final top = _translateY(boundingBox.top, size, imageSize, rotation);
    final right = _translateX(
        boundingBox.right, size, imageSize, rotation, cameraLensDirection);
    final bottom = _translateY(boundingBox.bottom, size, imageSize, rotation);

    canvas.drawRRect(
        RRect.fromLTRBR(left, top, right, bottom, const Radius.circular(12)),
        paintBox);

    // 2. Gambar Titik Bibir (Keren buat efek UI)
    final upperLipBottom =
        face.contours[FaceContourType.upperLipBottom]?.points ?? [];
    final lowerLipTop =
        face.contours[FaceContourType.lowerLipTop]?.points ?? [];

    for (var point in [...upperLipBottom, ...lowerLipTop]) {
      final px = _translateX(
          point.x.toDouble(), size, imageSize, rotation, cameraLensDirection);
      final py = _translateY(point.y.toDouble(), size, imageSize, rotation);
      canvas.drawCircle(Offset(px, py), 3, paintLip);
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) => true;

  double _translateX(double x, Size canvasSize, Size imageSize,
      InputImageRotation rotation, CameraLensDirection cameraLensDirection) {
    double scaleX = Platform.isAndroid
        ? canvasSize.width / imageSize.height
        : canvasSize.width / imageSize.width;
    double scaledX = x * scaleX;
    return cameraLensDirection == CameraLensDirection.front
        ? canvasSize.width - scaledX
        : scaledX;
  }

  double _translateY(
      double y, Size canvasSize, Size imageSize, InputImageRotation rotation) {
    double scaleY = Platform.isAndroid
        ? canvasSize.height / imageSize.width
        : canvasSize.height / imageSize.height;
    return y * scaleY;
  }
}
