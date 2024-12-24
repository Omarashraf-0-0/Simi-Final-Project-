import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/QuizGenerator/QuizOptions.dart'; // Ensure this import is correct and the file exists

class QuizHome extends StatefulWidget {
  const QuizHome({super.key});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // Blue color for the AppBar
        title: Text(
          'Quiz Generator',
          style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true, // Center the title in the AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('lib/assets/img/QuizTime.png'),
              SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Ready To Challenge Yourself? \n '),
                    TextSpan(
                      text: 'Lets Create Your Quiz!',
                      style: TextStyle(
                          color: const Color(0xFF165D96)), // Blue color for "Abo Layla"
                    ),
                  ],
                ),
              ),
              SizedBox(height: 150),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizOptions()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF165D96), // Button color
                  padding: EdgeInsets.symmetric(
                      horizontal: 70, vertical: 10), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button radius
                  ),
                ),
                child: Text(
                  'Start The Fun!',
                  style: TextStyle(
                    fontSize: 30, // Button text size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
