// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Courses.dart';
import 'package:studymate/pages/HomePage.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/MaterialCourses.dart';
import 'package:studymate/pages/Register_login.dart';
import 'pages/ProfilePage.dart';
import 'pages/intro_page.dart';

void main () async{
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  Materialcourses(),
      
      routes: {
        '/RegisterPage' : (context) => RegisterLogin(),
        '/IntroPage' : (context) => IntroPage(),
        '/HomePage' : (context) => Homepage(),
        '/LoginPage' : (context) => LoginPage(),
        '/ProfilePage' : (context) => Profilepage(),
        '/CoursesPage' : (context) => Courses(),
        '/Material' : (context) => Materialcourses(),
        }
        ,
    );
  }
}
