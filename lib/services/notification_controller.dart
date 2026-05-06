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
      final docId = action.payload?['docId'];

      navigatorKey.currentState?.pushNamed(
        '/camera',
        arguments: {
          'docId': docId,
        },
      );
    }
    if (action.buttonKeyPressed == 'SKIP') {
      final docId = action.payload?['docId'];

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
      _isProcessin = false;
    }
  }
}

