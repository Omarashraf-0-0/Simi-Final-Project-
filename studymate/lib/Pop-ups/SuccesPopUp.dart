// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../Classes/User.dart';
import '../pages/HomePage.dart';
import '../pages/LoginPage.dart';

class DonePopUp extends StatefulWidget {
  final String? title;
  final String? description;
  final Color? color;
  final Color? textColor;
  final String? icon;
  final String? routeName;
  User? user;

  DonePopUp({
    this.title,
    this.description,
    this.color,
    this.textColor,
    this.icon,
    this.routeName,
    this.user,
  });

  @override
  State<DonePopUp> createState() => _DonePopUpState();
}

class _DonePopUpState extends State<DonePopUp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularWidget(
              title: widget.title ?? "Default Title",
              description: widget.description ?? "Default Description",
              color: widget.color ?? Color(0xff3BBD5E),
              textColor: widget.textColor ?? Colors.black,
              routeName: widget.routeName ?? "/HomePage",
              user: widget.user,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final Color textColor;
  final String routeName;
  User? user;
  CircularWidget({
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
    required this.routeName,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60),
        // Lottie animation
        Lottie.asset(
          'lib/assets/animations/SuccesAnimation.json',
          height: 375,
          width: 375,
          fit: BoxFit.fill,
        ),
        SizedBox(height: 40), // Space between animation and title
        // Dynamic title text
        Text(
          title,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20), // Space between title and description
        // Dynamic description text
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30), // Space between text and button
        // Elevated Button for "Done"
        ElevatedButton(
          onPressed: () {
            // Close the app or perform another action
            // print("Done button pressed"); // Placeholder action
            if (routeName == "/HomePage") {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => routeName == "/HomePage" ? 
              Homepage(
                user: user,
              ) : LoginPage(
              )));
            } else {
              Navigator.popAndPushNamed(context, routeName, arguments: routeName);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Button color
            minimumSize: Size(320, 60),
          ),
          child: Text(
            "Done",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}