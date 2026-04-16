import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbmate_kmipn/widgets/custom_text_field.dart';
import 'package:tbmate_kmipn/widgets/custom_password_field.dart';

import 'package:tbmate_kmipn/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auto-Login Bypass untuk Development',
      (WidgetTester tester) async {
    app.main();

    // ==========================================
    // 🛑 KITA KASIH WAKTU 8 DETIK BUAT KAMU NGEKLIK "ALLOW"
    // ==========================================
    await Future.delayed(const Duration(seconds: 8));
    await tester.pumpAndSettle();

    final emailField = find.byType(CustomTextField).first;
    final passwordField = find.byType(CustomPasswordField).first;
    final tombolLogin = find.widgetWithText(ElevatedButton, 'Login');

    // Robot mulai bekerja setelah kamu selesai ngeklik pop-up OS
    await tester.enterText(
        emailField, 'pasien.asli@gmail.com'); // 👈 Sesuaikan emailmu
    await tester.enterText(
        passwordField, 'rahasia123'); // 👈 Sesuaikan passwordmu

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(tombolLogin);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tahan aplikasi tetap menyala untuk kamu coding
    await Future.delayed(const Duration(hours: 1));
  });
}
