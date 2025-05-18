import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  static Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    if (Platform.isAndroid) {
      // Android 13+ requires explicit permission
      await _messaging.requestPermission();
    }
  }

  static Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  static Future<void> initialize(
    void Function(String?) onSelectNotification,
  ) async {
    print(await _messaging.getToken());

    await _requestPermission();
    await _initializeLocalNotification(onSelectNotification);
    await _configureAndroidChannel();
    await _openInitialScreenFromMessage(onSelectNotification);
  }

  static void invokeLocalNotification(RemoteMessage remoteMessage) async {
    print("Received notification ${remoteMessage.data}");
    RemoteNotification? notification = remoteMessage.notification;
    AndroidNotification? android = notification?.android;

    if (notification != null && android != null) {
      await _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'BreakingCodeChannel', // id
            'High Importance Notifications', // name
            channelDescription: 'This channel is used for important notifications.',
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(remoteMessage.data),
      );
    }
  }

  static Future<void> _configureAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'BreakingCodeChannel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _openInitialScreenFromMessage(
    void Function(String?) onSelectNotification,
  ) async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage?.data != null) {
      onSelectNotification(jsonEncode(initialMessage!.data));
    }
  }

  static Future<void> _initializeLocalNotification(
    void Function(String?) onSelectNotification,
  ) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings();

    final initSetting = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotification.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification(response.payload);
      },
    );
  }
}
