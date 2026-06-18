import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin
      notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // =========================================================
  // INIT
  // =========================================================

  static Future<void> initialize() async {

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );

    const InitializationSettings settings =
        InitializationSettings(
          android: androidSettings,
        );

    await notificationsPlugin.initialize(settings);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // =========================================================
  // SEND NOTIFICATION
  // =========================================================

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'nuvit_channel',
          'NUVIT Alerts',
          channelDescription: 'Smart energy alerts',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details =
        NotificationDetails(
          android: androidDetails,
        );

    await notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}