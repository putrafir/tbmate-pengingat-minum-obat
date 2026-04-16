import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tbmate_kmipn/main.dart';
import 'package:tbmate_kmipn/pages/konfirmasi_popup.dart';
import 'alarm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma("vm:entry-point")
class NotificationController {
  // static Future<void> onActionReceived(ReceivedAction action) async {
  //   if (action.buttonKeyPressed == 'MINUM') {
  //     await AwesomeNotifications().cancel(action.id!);
  //   }

  //   if (action.buttonKeyPressed == 'SKIP') {
  //     await AlarmService.repeat5Minutes(action.id!);
  //   }
  // }
  static bool _isProcessin = false;
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction action) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceived(ReceivedAction action) async {
    if (_isProcessin) {
      debugPrint("DEBUG: Klik diabaikan karena sedang memproses...");
      return;
    }

    debugPrint(
        "DEBUG: Tombol ditekan -> ${action.buttonKeyPressed} (ID: ${action.id})");

    if (action.buttonKeyPressed == 'MINUM') {
      _isProcessin = true;
      await AwesomeNotifications().cancel(action.id!);
      _isProcessin = false;
    }
    if (action.buttonKeyPressed == 'SKIP') {
      _isProcessin = true;
      // await AwesomeNotifications().cancel(action.id!);
      final context = navigatorKey.currentContext;

      if (context != null) {
        final docId = action.payload?['docId'];
        debugPrint("DEBUG DOCID: $docId");

        KonfirmasiPopup.show(
            context: context,
            onConfirm: () async {},
            onAlasan: (alasan) async {
              await Firebase.initializeApp();

              final user = FirebaseAuth.instance.currentUser;
              final docId = action.payload?['docId'] ?? "";
              final id = action.id ?? 0;
              debugPrint("DEBUG USER: ${user?.uid}");
              debugPrint("DEBUG ALASAN: $alasan");

              if (user != null && docId != null && docId.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('jadwal_obat')
                    .doc(docId)
                    .update({
                  "status": "Ditunda",
                  "alasan_tunda": alasan,
                  "waktu_tunda": FieldValue.serverTimestamp(),
                });
              }
              // await AlarmService.repeatSnooze(
              //   action.id!,
              //   const Duration(minutes: 1),
              // );
              AlarmService.repeatSnooze(
                id,
                Duration(minutes: 5),
                docId,
              );
              _isProcessin = false;
            });
      } else {
        _isProcessin = false;
      }
    }
    if (action.buttonKeyPressed.isEmpty) {
      print("DEBUG: user mengklik nody notifikasi.");
      _isProcessin = false;
    }
  }
}
