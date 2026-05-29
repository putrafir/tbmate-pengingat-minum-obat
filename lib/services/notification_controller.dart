import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  static bool _isProcessing = false;
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
    if (_isProcessing) {
      debugPrint("DEBUG: Klik diabaikan karena sedang memproses...");
      return;
    }

    debugPrint(
        "DEBUG: Tombol ditekan -> ${action.buttonKeyPressed} (ID: ${action.id})");

    if (action.buttonKeyPressed == 'MINUM') {
      final docId = action.payload?['docId'];

      navigatorKey.currentState?.pushNamed(
        '/camera',
        arguments: {
          'docId': docId,
        },
      );
      _isProcessing = true;
      await AwesomeNotifications().cancel(action.id!);
      _isProcessing = false;
    }
    if (action.buttonKeyPressed == 'SKIP') {
      _isProcessing = true;
      final docId = action.payload?['docId'];
      debugPrint("DEBUG: Tombol SKIP ditekan");
      debugPrint("DEBUG: docId -> $docId");

      await AwesomeNotifications().cancel(action.id!);

      if (docId != null) {
        await AlarmService.repeatSnooze(
          action.id!,
          const Duration(minutes: 1),
          docId,
        );
      }

      final context = navigatorKey.currentContext;

      if (context != null && docId != null) {
        KonfirmasiPopup.show(
          context: context,
          onConfirm: () async {
            debugPrint('Debug popup confirm ditutup');
          },
          onAlasan: (String alasan) async {
            debugPrint('Debug: alasn -> $alasan');

            try {
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('jadwal_obat')
                  .doc(docId)
                  .update({
                "status": "Ditunda",
                "riwayat_tunda": FieldValue.arrayUnion([
                  {
                    "alasan_tunda": alasan,
                    "waktu_tunda": Timestamp.now(),
                  }
                ])
              });
              debugPrint('DEBUG: alasan berhasil disimpan');
            } catch (e) {
              debugPrint('DEBUG: gagal simpan alasan ->$e');
            }
          },
        );
      }
      _isProcessing = false;
      navigatorKey.currentContext?.go(
        '/main-screen',
        extra: {
          'showPopup': true,
          'docId': docId,
        },
      );
    }
    if (action.buttonKeyPressed.isEmpty) {
      print("DEBUG: user mengklik nody notifikasi.");
      _isProcessing = false;
    }
  }
}
