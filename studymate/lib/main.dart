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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This file is generated by FlutterFire CLI
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:studymate/pages/Career/CareerHome.dart';

// تعريف متغير FlutterLocalNotificationsPlugin على مستوى عام
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// تعريف المفتاح العام للـ Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message ${message.messageId}');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await FlutterDownloader.initialize(
    debug: true, // Set to false to disable debug logs
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // تهيئة المنطقة الزمنية
  tz.initializeTimeZones();

  // إعدادات التهيئة للنوتيفيكيشن
  await _initializeNotifications();

  // طلب الأذونات للنوتيفيكيشن
  await _requestPermissions();
  rrequestPermission();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp( MyApp());
}
class MyApp extends StatefulWidget {
    const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
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
        '/CareerHome': (context) => CareerHome(),
        '/CourseContent': (context) => CourseContent(),
        '/Resources': (context) => Resources(),
      },
    );
  }
}
class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    // Call the asynchronous methods
    _requestPermission();
    _getToken();
    _initializeFlutterNotifications();
    _setupForegroundMessageHandler();
  }

  // Separate method to request permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Separate method to get the device token
  Future<void> _getToken() async {
    _deviceToken = await _messaging.getToken();
    print('Device Token: $_deviceToken');

    // Send the token to your server or save it as needed

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // Handle token refresh
      _deviceToken = newToken;
      print('New Device Token: $_deviceToken');
      // Update token on your server if necessary
    });
  }

  // Separate method to initialize local notifications
  Future<void> _initializeFlutterNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create the notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // Set up foreground message handler
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // Display the notification using flutter_local_notifications
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // Handle notification taps when the app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened!');
      // Navigate to a specific screen if needed
    });
  }

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
        '/CareerHome': (context) => CareerHome()
      },
    );
  }
}
// class _MyAppState extends State<MyApp> {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // name
//     description: 'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );

//   @override
//   Future<void> initState()  {
//     super.initState();

//     // Request notification permissions
//     requestPermission();
    
//     // Initialize flutter local notifications
//     _initializeNotifications();
//     setupFlutterNotifications();
    
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Foreground message received: ${message.messageId}');

//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;

//       if (notification != null && android != null) {
//         // Show a notification
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               channelDescription: channel.description,
//               importance: Importance.max,
//               priority: Priority.high,
//               icon: '@mipmap/ic_launcher',
//             ),
//           ),
//         );
//       }
//     });

//     // Handle when a user clicks on a notification and the app is opened
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Notification clicked!');
//       // Navigate to a specific screen if needed
//     });
//   }
 
//   Future<void> requestPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false, // Set to true if your app uses SiriKit
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission.');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('User granted provisional permission.');
//     } else {
//       print('User declined or has not accepted permission.');
//     }
//   }
// Future<void> _initializeNotifications() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//       String? token = await messaging.getToken();

//       print('Device Token: $token');
// }
//   Future<void> setupFlutterNotifications() async {
//     // Initialize the flutter local notifications plugin
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Create the channel for Android devices
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Push Notifications',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Push Notifications Example'),
//         ),
//         body: Center(
//           child: Text('Welcome to My App!'),
//         ),
//       ),
//     );
//   }
// }
// // دالة لتهيئة النوتيفيكيشن
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

Future<void> rrequestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
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

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey, // Add the global key here
//       debugShowCheckedModeBanner: false,
//       home: IntroPage(),
//       routes: {
//         '/RegisterPage': (context) => RegisterLogin(),
//         '/IntroPage': (context) => IntroPage(),
//         '/HomePage': (context) => Homepage(),
//         '/LoginPage': (context) => LoginPage(),
//         '/ProfilePage': (context) => Profilepage(),
//         '/CoursesPage': (context) => Courses(),
//         '/Material': (context) => Materialcourses(),
//         '/SRS': (context) => SRS(),
//         '/CourseContent': (context) => CourseContent(),
//         '/Resources': (context) => Resources(),
//       },
//     );
//   }
// }

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
