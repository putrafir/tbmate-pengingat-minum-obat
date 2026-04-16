import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbmate_kmipn/widgets/custom_text_field.dart';
import 'package:tbmate_kmipn/widgets/custom_password_field.dart';

// 🔹 PENTING: Ubah import ini sesuai dengan lokasi file main.dart kamu
import 'package:tbmate_kmipn/main.dart' as app;

void main() {
  // Inisialisasi engine tester
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Robot Test: Flow Login dengan Akun Salah',
      (WidgetTester tester) async {
    // 1. Suruh robot menjalankan aplikasinya dari awal
    app.main();

    // Tunggu sampai animasi pembuka aplikasi selesai
    await tester.pumpAndSettle();

    // 2. Minta robot mencari kolom input berdasarkan tipe Widget yang kamu buat
    final emailField = find.byType(CustomTextField);
    final passwordField = find.byType(CustomPasswordField);

    // Minta robot mencari tombol yang ada teks "Login"
    // (Kita pakai spesifik ElevatedButton agar tidak keliru dengan teks judul)
    final tombolLogin = find.widgetWithText(ElevatedButton, 'Login');

    // Robot memastikan semua komponen itu beneran ada di layar
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(tombolLogin, findsOneWidget);

    // 3. Robot mulai mengetik kredensial palsu
    await tester.enterText(emailField, 'pasien.palsu@gmail.com');
    await tester.pump(); // Render ulang UI setelah ngetik

    await tester.enterText(passwordField, 'passwordngasal123');
    await tester.pump();

    // 4. Tutup keyboard agar tidak menutupi tombol Login
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // 5. Robot ngeklik tombol Login!
    await tester.tap(tombolLogin);

    // Kita panggil pump() satu kali untuk memicu setState (isLoading = true)
    await tester.pump();

    // 6. Verifikasi: Apakah indikator loading (CircularProgressIndicator) muncul?
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 7. Tunggu respon dari server Firebase (bisa memakan waktu beberapa detik)
    // pumpAndSettle akan menunggu sampai indikator loading hilang (isLoading = false)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 8. Verifikasi Akhir: Karena akunnya salah, harusnya muncul SnackBar error!
    final snackBarError = find.text("Email atau password salah!");
    expect(snackBarError, findsOneWidget);
  });
}
