import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.getToken();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('FCM message received: ${message.notification?.title}');
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Push notifications disabled: $e');
      }
    }
  }
}
