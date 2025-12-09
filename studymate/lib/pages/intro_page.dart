// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/Classes/User.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:flutter_test/flutter_test.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() {
    if (!isLoggedIn()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Student user = Student();
      user.fullName = Hive.box('userBox').get('fullName');
      user.email = Hive.box('userBox').get('email');
      user.password = Hive.box('userBox').get('password');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Homepage(
                    student: user,
                  )));
    }
  }

  bool isLoggedIn() {
    Box userBox = Hive.box('userBox');
    bool loggedIn = userBox.get('isLoggedIn', defaultValue: false);

    if (loggedIn) {
      int loginTime = userBox.get('loginTime', defaultValue: 0);
      DateTime loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      Duration durationSinceLogin = DateTime.now().difference(loginDateTime);

      // Check if the session has expired (30 minutes)
      if (durationSinceLogin.inMinutes > 30) {
        logout();
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    Box userBox = Hive.box('userBox');
    await userBox.put('isLoggedIn', false);
    await userBox.put('loginTime', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //++++++++++++++++++++++++++++++++++++++++++++++
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png'),
          ],
        ),
      ),
    );
  }
}
