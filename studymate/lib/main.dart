// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Login%20&%20Register/Register_login.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Courses.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/Resuorces/MaterialCourses.dart';
import 'package:studymate/pages/Login & Register/Register_login.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Resuorces/urlLuncher.dart';
import 'pages/ProfilePage.dart';
import 'pages/intro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await FlutterDownloader.initialize(
    debug: true, // Set to false to disable debug logs
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  IntroPage(),
      
      routes: {
        '/RegisterPage' : (context) => RegisterLogin(),
        '/IntroPage' : (context) => IntroPage(),
        '/HomePage' : (context) => Homepage(),
        '/LoginPage' : (context) => LoginPage(),
        '/ProfilePage' : (context) => Profilepage(),
        '/CoursesPage' : (context) => Courses(),
        '/Material' : (context) => Materialcourses(),
        '/SRS' : (context) => SRS(),
        '/CourseContent' : (context) => CourseContent(),
        '/Resources' : (context) => Resources(),
        // '/UrlLauncherPage' : (context) => UrlLauncherPage(),
        // '/MaterialCourses' : (context) => MaterialCourses(pdfUrl: '',),
        }
        ,
    );
  }
}
