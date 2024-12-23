// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Login%20&%20Register/Register_login.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Courses.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/Resuorces/MaterialCourses.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'pages/ProfilePage.dart';
import 'pages/intro_page.dart';
import 'pages/Notifications/Notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// تعريف متغير FlutterLocalNotificationsPlugin على مستوى عام
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// تعريف المفتاح العام للـ Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await FlutterDownloader.initialize(
    debug: true, // Set to false to disable debug logs
  );

  // تهيئة المنطقة الزمنية
  tz.initializeTimeZones();

  // إعدادات التهيئة للنوتيفيكيشن
  await _initializeNotifications();

  // طلب الأذونات للنوتيفيكيشن
  await _requestPermissions();

  runApp(const MyApp());
}

// دالة لتهيئة النوتيفيكيشن
Future<void> _initializeNotifications() async {
  // إعدادات Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // إعدادات iOS
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // دمج الإعدادات
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // تهيئة الـ FlutterLocalNotificationsPlugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // التعامل مع النوتيفيكيشن عند الضغط عليها
      if (notificationResponse.payload != null) {
        // navigatorKey.currentState?.push(
          // MaterialPageRoute(builder: (context) => NotificationPage(notifications: [],)),
        // );
      }
    },
  );
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.notification.request().isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  } else if (Platform.isIOS) {
    final iosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != null) {
        // الإذن ممنوح
        print('Notification permission granted');
      } else {
        // الإذن مرفوض
        print('Notification permission denied');
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add the global key here
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      routes: {
        '/RegisterPage': (context) => RegisterLogin(),
        '/IntroPage': (context) => IntroPage(),
        '/HomePage': (context) => Homepage(),
        '/LoginPage': (context) => LoginPage(),
        '/ProfilePage': (context) => Profilepage(),
        '/CoursesPage': (context) => Courses(),
        '/Material': (context) => Materialcourses(),
        '/SRS': (context) => SRS(),
        '/CourseContent': (context) => CourseContent(),
        '/Resources': (context) => Resources(),
      },
    );
  }
}

// دوال لإظهار وجدولة النوتيفيكيشن

Future<void> showNotification(String title, String info) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // معرّف القناة
    'Your Channel Name', // اسم القناة
    channelDescription: 'Your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // رقم تعريف النوتيفيكيشن
    title,
    info,
    platformChannelSpecifics,
    payload: 'What is this?',
  );
}



Future<void> scheduleNotification({
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  // Convert DateTime to TZDateTime for timezone compatibility
  final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    scheduledDate.millisecondsSinceEpoch ~/ 1000, // Unique notification ID
    title, // Notification title
    body,  // Notification body
    tzScheduledDate, // Time to show the notification
    const NotificationDetails(
      android: AndroidNotificationDetails(
        '1', // Replace with your channel ID
        'Your Channel Name', // Replace with your channel name
        channelDescription: 'Your channel description', // Optional description
        importance: Importance.max, // High visibility
        priority: Priority.high, // High priority
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  print('Notification scheduled for: $tzScheduledDate');
}
