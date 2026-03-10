import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:tbmate_kmipn/pages/beratbadan.dart'; 
import 'package:tbmate_kmipn/pages/settime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // <--- Inisialisasi locale Indonesia

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SetWaktu(), // contoh panggilan
    );
  }
}
