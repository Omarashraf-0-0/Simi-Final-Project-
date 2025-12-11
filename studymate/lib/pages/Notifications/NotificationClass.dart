import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // ✅ Singleton setup
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Call this once during app startup
  Future<void> init() async {
    tz.initializeTimeZones(); // Important for scheduled notifications
    await _requestFirebasePermissions();
    await _requestLocalPermissions();
    await _initializeLocalNotifications();
  }

  // ✅ Firebase permissions
  Future<void> _requestFirebasePermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Firebase: Permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Firebase: Provisional permission granted');
    } else {
      print('❌ Firebase: Permission denied');
    }
  }

  // ✅ Local notification permissions
  Future<void> _requestLocalPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.request();
      print(status.isGranted
          ? '✅ Android: Notification permission granted'
          : '❌ Android: Notification permission denied');
    } else if (Platform.isIOS) {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print(granted != null && granted
            ? '✅ iOS: Notification permission granted'
            : '❌ iOS: Notification permission denied');
      }
    }
  }

  // ✅ Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  // ✅ Show immediate local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'This is the default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  // ✅ Schedule notification for a specific time
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Convert DateTime to TZDateTime for timezone compatibility
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch ~/ 1000, // Unique notification ID
      title, // Notification title
      body, // Notification body
      tzScheduledDate, // Time to show the notification
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '1', // Replace with your channel ID
          'Your Channel Name', // Replace with your channel name
          channelDescription:
              'Your channel description', // Optional description
          importance: Importance.max, // High visibility
          priority: Priority.high, // High priority
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // print('Notification scheduled for: $tzScheduledDate');
  }
//   Future<void> scheduleNotification({
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     final tz.TZDateTime tzScheduledDate =
//         tz.TZDateTime.from(scheduledDate, tz.local);

//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'scheduled_channel_id',
//       'Scheduled Notifications',
//       channelDescription: 'Channel for scheduled notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );

//     await _flutterLocalNotificationsPlugin.zonedSchedule(

//       title,
//       body,
//       tzScheduledDate,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time, // Optional
//     );
//   }
}
