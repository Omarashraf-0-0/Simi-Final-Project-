import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  static Future<void> _requestPermission() async {
    try {
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
    } catch (e) {
      print('⚠️ Error requesting Firebase permissions: $e');
      // Continue without Firebase permissions
    }
  }

  // Safe stream getters with error handling
  static Stream<RemoteMessage> get onMessage {
    try {
      return FirebaseMessaging.onMessage;
    } catch (e) {
      print('⚠️ Error accessing Firebase onMessage stream: $e');
      return Stream.empty(); // Return empty stream if Firebase is unavailable
    }
  }

  static Stream<RemoteMessage> get onMessageOpenedApp {
    try {
      return FirebaseMessaging.onMessageOpenedApp;
    } catch (e) {
      print('⚠️ Error accessing Firebase onMessageOpenedApp stream: $e');
      return Stream.empty(); // Return empty stream if Firebase is unavailable
    }
  }

  static Future<void> initialize(
    void Function(String?) onSelectNotification,
  ) async {
    try {
      final token = await _messaging.getToken();
      print('📱 FCM Token: $token');

      await _requestPermission();
      await _initializeLocalNotification(onSelectNotification);
      await _configureAndroidChannel();
      await _openInitialScreenFromMessage(onSelectNotification);
    } catch (e) {
      print('⚠️ Firebase Messaging initialization error: $e');
      print(
          '📱 App will continue without FCM. Local notifications will still work.');
      // Initialize local notifications even if FCM fails
      try {
        await _initializeLocalNotification(onSelectNotification);
        await _configureAndroidChannel();
      } catch (localError) {
        print('❌ Local notification initialization error: $localError');
      }
    }
  }

  static void invokeLocalNotification(RemoteMessage remoteMessage) async {
    print("Received notification ${remoteMessage.data}");
    RemoteNotification? notification = remoteMessage.notification;
    AndroidNotification? android = notification?.android;

    // Store notification in database
    await _storeNotificationInDatabase(
      title: notification?.title ?? 'New Notification',
      body: notification?.body ?? '',
    );

    if (notification != null && android != null) {
      await _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'BreakingCodeChannel', // id
            'High Importance Notifications', // name
            channelDescription:
                'This channel is used for important notifications.',
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(remoteMessage.data),
      );
    }
  }

  // Store notification in backend database
  static Future<void> _storeNotificationInDatabase({
    required String title,
    required String body,
  }) async {
    try {
      final userBox = Hive.box('userBox');
      final userId = userBox.get('id');

      if (userId == null) {
        print('User ID not found, cannot store notification');
        return;
      }

      const url = 'https://alyibrahim.pythonanywhere.com/storeNotification';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'body': body,
          'type': 'fcm', // Mark as FCM notification
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification stored in database');
      } else {
        print('❌ Failed to store notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error storing notification: $e');
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
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage?.data != null) {
        onSelectNotification(jsonEncode(initialMessage!.data));
      }
    } catch (e) {
      print('⚠️ Error getting initial message: $e');
      // Continue without initial message
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
