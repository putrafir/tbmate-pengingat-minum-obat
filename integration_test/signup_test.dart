import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbmate_kmipn/widgets/custom_text_field.dart';
import 'package:tbmate_kmipn/widgets/custom_password_field.dart';

// 🔹 PENTING: Ubah import ini sesuai dengan lokasi file main.dart kamu
import 'package:tbmate_kmipn/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Robot Test: Flow Sign Up dan Validasi Form',
      (WidgetTester tester) async {
    // 1. Jalankan aplikasi (Biasanya mulai dari Login)
    app.main();
    await tester.pumpAndSettle();

    // 2. Cari teks "Sign Up" untuk pindah ke halaman registrasi
    final linkSignUp = find.textContaining('Sign Up');
    expect(linkSignUp, findsWidgets);
    await tester.tap(linkSignUp.first);

    // Tunggu animasi pindah halaman selesai
    await tester.pumpAndSettle();

    // 3. Kenali semua kolom input di halaman Sign Up
    final emailField = find.byType(CustomTextField);

    // Karena ada 2 password field, kita tangkap keduanya
    final passwordFields = find.byType(CustomPasswordField);
    final passwordField = passwordFields.at(0); // Kolom Password
    final confirmPasswordField = passwordFields.at(1); // Kolom Confirm Password

    final checkbox = find.byType(Checkbox);
    final tombolDaftar = find.widgetWithText(ElevatedButton, 'Sign Up');

    // Pastikan semua komponen ditemukan oleh robot
    expect(emailField, findsOneWidget);
    expect(checkbox, findsOneWidget);
    expect(tombolDaftar, findsOneWidget);

    // ==========================================
    // 🛑 SKENARIO 1: PASSWORD TIDAK SAMA
    // ==========================================
    await tester.enterText(emailField, 'pasien.baru@gmail.com');
    await tester.enterText(passwordField, 'rahasia123');
    await tester.enterText(
        confirmPasswordField, 'salahketik123'); // Sengaja dibikin beda

    FocusManager.instance.primaryFocus?.unfocus(); // Tutup keyboard
    await tester.pumpAndSettle();

    await tester.tap(tombolDaftar);
    await tester.pumpAndSettle();

    // Robot ngecek apakah SnackBar error password muncul
    expect(find.text("Password dan konfirmasi tidak sama"), findsOneWidget);

    // ==========================================
    // 🛑 SKENARIO 2: LUPA CENTANG SYARAT & KETENTUAN
    // ==========================================
    // Tunggu sebentar sampai SnackBar sebelumnya hilang
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Robot membenarkan confirm password agar sama
    await tester.enterText(confirmPasswordField, 'rahasia123');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Robot langsung klik daftar (tanpa centang checkbox)
    await tester.tap(tombolDaftar);
    await tester.pumpAndSettle();

    // Robot ngecek apakah SnackBar error checkbox muncul
    expect(
        find.text("Kamu harus menyetujui syarat & ketentuan"), findsOneWidget);

    // ==========================================
    // ✅ SKENARIO 3: FLOW SUKSES
    // ==========================================
    // Tunggu SnackBar hilang
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Robot akhirnya mencentang checkbox
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Robot klik daftar
    await tester.tap(tombolDaftar);
    await tester.pump(); // Pakai pump 1x karena ada state isLoading = true

    // Robot ngecek apakah indikator loading muncul tanda proses Firebase berjalan
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Kita stop di sini agar tidak menyampah (spam) data ke Firebase sungguhan saat testing
  });
}
