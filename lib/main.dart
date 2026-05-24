import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart'; // Ini kepakai
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tbmate_kmipn/app_router.dart';
import 'package:tbmate_kmipn/services/alarm_service.dart';
import 'package:tbmate_kmipn/services/notification_controller.dart';
import 'firebase_options.dart'; // Ini kepakai
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 🔹 TAHAN NATIVE SPLASH
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 🔹 JANGAN LUPA FIREBASE-NYA! (Tadi terhapus di kodemu)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  await AlarmService.init();

  // 🔹 Listener TETAP di sini
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceived,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod,
  );

  await initializeDateFormatting('id_ID', null);

  runApp(const TBMateApp());
}

class TBMateApp extends StatefulWidget {
  const TBMateApp({super.key});

  @override
  State<TBMateApp> createState() => _TBMateAppState();
}

class _TBMateAppState extends State<TBMateApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'TBMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    );
  }
}
