// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'pages/RegisterPage.dart';
import 'pages/intro_page.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IntroPage(),
      routes: {
        '/RegisterPage' : (context) => RegisterPage(),
        }
        ,
    );
  }
}
