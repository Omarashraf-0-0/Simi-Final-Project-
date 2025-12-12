import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

// Import for navigation handling
import '../main.dart' show handleNotificationNavigation;

/// Enhanced Notification Service
/// Handles: Scheduled notifications, FCM, Rank achievements, Quiz reminders, etc.
class EnhancedNotificationService {
  // Singleton pattern
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  // Notification channels
  static const String _scheduleChannelId = 'schedule_notifications';
  static const String _rankChannelId = 'rank_notifications';
  static const String _quizChannelId = 'quiz_notifications';
  static const String _generalChannelId = 'general_notifications';
  static const String _reminderChannelId = 'reminder_notifications';

  /// Initialize the notification service
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo')); // Set your timezone

    await _requestPermissions();
    await _initializeLocalNotifications();
    await _createNotificationChannels();
    await _initializeFirebaseMessaging();
    await _loadLastRank(); // Load saved rank for comparison
  }

  /// Request all necessary permissions
  Future<void> _requestPermissions() async {
    // Firebase permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      criticalAlert: false,
    );

    print('✅ Firebase Permission: ${settings.authorizationStatus}');

    // Android notification permission (Android 13+)
    if (Platform.isAndroid) {
      var status = await Permission.notification.request();
      print('✅ Android Notification Permission: ${status.isGranted}');

      // Request exact alarm permission for scheduled notifications
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }

    // iOS specific permissions
    if (Platform.isIOS) {
      final iosPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification actions based on type
  void _handleNotificationAction(Map<String, dynamic> data) {
    // Note: Navigation should be handled in the app's notification handler
    // This is just for logging/debugging
    final type = data['type'];
    print('Notification tapped - Type: $type, Data: $data');
    // The actual navigation will be handled by the app using the global navigator key
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Schedule Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _scheduleChannelId,
          'Schedule Notifications',
          description: 'Notifications for scheduled classes and events',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Rank Achievement Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _rankChannelId,
          'Rank Achievements',
          description: 'Notifications for rank ups and achievements',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );

      // Quiz Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _quizChannelId,
          'Quiz Reminders',
          description: 'Notifications for upcoming quizzes',
          importance: Importance.high,
          playSound: true,
        ),
      );

      // General Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
        ),
      );

      // Reminder Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Study Reminders',
          description: 'Daily study reminders and motivational messages',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');

      // Save token to backend
      if (_fcmToken != null) {
        await _saveFCMTokenToBackend(_fcmToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFCMTokenToBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message opened from background/terminated state
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // iOS foreground notification presentation
      if (Platform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('⚠️ Firebase Messaging initialization error: $e');
      print(
          '📱 App will continue without FCM. Local notifications will still work.');
      // Don't throw - allow app to continue without FCM
    }
  }

  /// Save FCM token to backend
  Future<void> _saveFCMTokenToBackend(String token) async {
    try {
      final userBox = Hive.box('userBox');
      final username = userBox.get('username');

      if (username == null) return;

      await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/save_fcm_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'fcm_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );

      print('✅ FCM token saved to backend');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        channelId: _generalChannelId,
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle message opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📨 Message opened: ${message.data}');
    _handleNotificationAction(message.data);
  }

  /// Show immediate notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    Map<String, dynamic>? data,
  }) async {
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: data != null ? jsonEncode(data) : null,
    );

    // Store scheduled notification in database with appropriate type
    final notificationType = _getNotificationTypeFromChannel(channelId);
    await _storeNotificationInDatabase(
      title: title,
      body: body,
      type: notificationType,
      metadata: data,
    );

    print('✅ Scheduled notification: $title at $scheduledDate');
  }

  /// Schedule class/lecture notification (15 min before)
  Future<void> scheduleClassNotification({
    required String className,
    required DateTime classTime,
    required String location,
  }) async {
    final notificationTime = classTime.subtract(const Duration(minutes: 15));

    if (notificationTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: classTime.millisecondsSinceEpoch ~/ 1000,
        title: '📚 Upcoming Class',
        body: '$className starts in 15 minutes at $location',
        scheduledDate: notificationTime,
        channelId: _scheduleChannelId,
        data: {
          'type': 'schedule',
          'className': className,
          'time': classTime.toIso8601String(),
        },
      );
    }
  }

  /// Schedule quiz reminder (1 day and 1 hour before)
  Future<void> scheduleQuizReminders({
    required String quizName,
    required DateTime quizTime,
    String? quizId,
  }) async {
    // 1 day before
    final dayBeforeTime = quizTime.subtract(const Duration(days: 1));
    if (dayBeforeTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: (quizTime.millisecondsSinceEpoch ~/ 1000) - 86400,
        title: '📝 Quiz Tomorrow!',
        body:
            'Don\'t forget: $quizName is tomorrow at ${_formatTime(quizTime)}',
        scheduledDate: dayBeforeTime,
        channelId: _quizChannelId,
        data: {
          'type': 'quiz',
          'quizId': quizId,
          'quizName': quizName,
        },
      );
    }

    // 1 hour before
    final hourBeforeTime = quizTime.subtract(const Duration(hours: 1));
    if (hourBeforeTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: (quizTime.millisecondsSinceEpoch ~/ 1000) - 3600,
        title: '⏰ Quiz in 1 Hour!',
        body: '$quizName starts soon. Good luck! 🍀',
        scheduledDate: hourBeforeTime,
        channelId: _quizChannelId,
        data: {
          'type': 'quiz',
          'quizId': quizId,
          'quizName': quizName,
        },
      );
    }
  }

  /// Schedule assignment deadline reminder
  Future<void> scheduleAssignmentReminder({
    required String assignmentName,
    required DateTime deadline,
    String? assignmentId,
  }) async {
    // 2 days before
    final twoDaysBeforeTime = deadline.subtract(const Duration(days: 2));
    if (twoDaysBeforeTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: (deadline.millisecondsSinceEpoch ~/ 1000) - 172800,
        title: '📋 Assignment Due in 2 Days',
        body: '$assignmentName is due soon!',
        scheduledDate: twoDaysBeforeTime,
        channelId: _reminderChannelId,
        data: {
          'type': 'assignment',
          'assignmentId': assignmentId,
        },
      );
    }

    // 1 day before
    final dayBeforeTime = deadline.subtract(const Duration(days: 1));
    if (dayBeforeTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: (deadline.millisecondsSinceEpoch ~/ 1000) - 86400,
        title: '⚠️ Assignment Due Tomorrow!',
        body: 'Last chance: $assignmentName is due tomorrow!',
        scheduledDate: dayBeforeTime,
        channelId: _reminderChannelId,
        data: {
          'type': 'assignment',
          'assignmentId': assignmentId,
        },
      );
    }
  }

  /// Check and notify rank changes
  Future<void> checkRankChange(int newXP) async {
    final userBox = Hive.box('userBox');
    final oldRank = userBox.get('lastNotifiedRank', defaultValue: 'Beginner');
    final newRank = _calculateRankFromXP(newXP);

    if (oldRank != newRank) {
      await _showRankUpNotification(oldRank, newRank, newXP);
      await userBox.put('lastNotifiedRank', newRank);
    }
  }

  /// Show rank up notification
  Future<void> _showRankUpNotification(
      String oldRank, String newRank, int xp) async {
    final messages = {
      'Explorer': '🎯 You\'re now an Explorer! Keep discovering!',
      'Achiever': '⭐ Amazing! You\'ve reached Achiever status!',
      'Challenger': '🔥 Challenger unlocked! You\'re on fire!',
      'Expert': '🎓 Expert level reached! Impressive skills!',
      'Mentor': '👑 Mentor rank achieved! Guide others with your wisdom!',
      'Legend': '🌟 LEGENDARY! You\'ve reached the highest rank!',
      'El Batal': '🏆 EL BATAL! You are the ultimate champion!',
    };

    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎉 Rank Up! Welcome to $newRank!',
      body: messages[newRank] ?? 'Congratulations on your new rank!',
      channelId: _rankChannelId,
      payload: jsonEncode({
        'type': 'rank',
        'oldRank': oldRank,
        'newRank': newRank,
        'xp': xp,
      }),
    );
  }

  /// Schedule daily study reminder
  Future<void> scheduleDailyStudyReminder({
    required TimeOfDay time,
    String? customMessage,
  }) async {
    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final messages = [
      '📚 Time to study! Your future self will thank you.',
      '🎯 Let\'s crush today\'s goals together!',
      '💪 Study time! Small steps lead to big achievements.',
      '⏰ Your daily study session awaits!',
      '🌟 Make today count! Time to hit the books.',
    ];

    await scheduleNotification(
      id: 999999, // Fixed ID for daily reminder
      title: '📖 Daily Study Reminder',
      body: customMessage ?? messages[DateTime.now().day % messages.length],
      scheduledDate: scheduledDate,
      channelId: _reminderChannelId,
      data: {'type': 'daily_reminder'},
    );
  }

  /// Show milestone notification (e.g., 10 quizzes completed)
  Future<void> showMilestoneNotification({
    required String milestone,
    required String description,
  }) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎊 Milestone Achieved!',
      body: '$milestone - $description',
      channelId: _rankChannelId,
      payload: jsonEncode({'type': 'milestone', 'milestone': milestone}),
    );
  }

  /// Show streak notification
  Future<void> showStreakNotification(int days) async {
    String emoji = days >= 30
        ? '🔥🔥🔥'
        : days >= 7
            ? '🔥🔥'
            : '🔥';

    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '$emoji $days Day Streak!',
      body: days >= 30
          ? 'Incredible! You\'re unstoppable!'
          : days >= 7
              ? 'A week strong! Keep it going!'
              : 'Great start! Don\'t break the chain!',
      channelId: _rankChannelId,
      payload: jsonEncode({'type': 'streak', 'days': days}),
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Store notification in backend database
  Future<void> _storeNotificationInDatabase({
    required String title,
    required String body,
    String type = 'scheduled',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userBox = Hive.box('userBox');
      final userId = userBox.get('id');

      if (userId == null) {
        print('User ID not found, cannot store notification');
        return;
      }

      const url = 'https://alyibrahim.pythonanywhere.com/storeNotification';

      final requestBody = {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
      };

      // Add metadata if provided
      if (metadata != null) {
        requestBody['metadata'] = metadata;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
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

  // Helper methods
  String _getChannelName(String channelId) {
    switch (channelId) {
      case _scheduleChannelId:
        return 'Schedule Notifications';
      case _rankChannelId:
        return 'Rank Achievements';
      case _quizChannelId:
        return 'Quiz Reminders';
      case _reminderChannelId:
        return 'Study Reminders';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _scheduleChannelId:
        return 'Notifications for scheduled classes and events';
      case _rankChannelId:
        return 'Notifications for rank ups and achievements';
      case _quizChannelId:
        return 'Notifications for upcoming quizzes';
      case _reminderChannelId:
        return 'Daily study reminders and motivational messages';
      default:
        return 'General app notifications';
    }
  }

  String _calculateRankFromXP(int xp) {
    if (xp >= 3500) return 'El Batal';
    if (xp >= 2500) return 'Legend';
    if (xp >= 1700) return 'Mentor';
    if (xp >= 1100) return 'Expert';
    if (xp >= 650) return 'Challenger';
    if (xp >= 350) return 'Achiever';
    if (xp >= 150) return 'Explorer';
    return 'Beginner';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getNotificationTypeFromChannel(String channelId) {
    switch (channelId) {
      case _scheduleChannelId:
        return 'schedule';
      case _rankChannelId:
        return 'rank';
      case _quizChannelId:
        return 'quiz';
      case _reminderChannelId:
        return 'assignment';
      case _generalChannelId:
        return 'general';
      default:
        return 'other';
    }
  }

  Future<void> _loadLastRank() async {
    final userBox = Hive.box('userBox');
    final xp = userBox.get('xp', defaultValue: 0);
    final currentRank = _calculateRankFromXP(xp);

    if (!userBox.containsKey('lastNotifiedRank')) {
      await userBox.put('lastNotifiedRank', currentRank);
    }
  }
}
