import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class QuizScore extends StatefulWidget {
  final int score; // النتيجة
  final int total; // الإجمالي
  final List<int> userAnswers;
  final List<Map<String, dynamic>> questions;

  const QuizScore({
    super.key,
    required this.score,
    required this.total,
    required this.userAnswers,
    required this.questions,
  });

  @override
  State<QuizScore> createState() => _QuizScoreState();
}

class _QuizScoreState extends State<QuizScore> {
  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.total;
    bool isPass = percentage >= 0.5;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96), // لون AppBar
        title: const Text(
          'Mission Done',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Score is',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'League Spartan',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 120),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 13.0,
              animation: true,
              percent: percentage,
              center: Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: isPass ? Colors.green : Colors.red,
                  fontFamily: 'League Spartan',
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: isPass ? Colors.green : Colors.red,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              isPass
                  ? 'Congratulations!\nYou Nailed It! Keep Up The Amazing Work'
                  : 'Oops!\nBetter Luck Next Time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPass ? Colors.green : Colors.red,
                fontFamily: 'League Spartan',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => ReviewPage(
                //       questions: widget.questions,
                //       userAnswers: widget.userAnswers,
                //     ),
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPass ? Colors.green : Colors.red, // لون الزر
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // حواف الزر
                ),
              ),
              child: const Text(
                'View Answers',
                style: TextStyle(
                  fontSize: 20, // حجم النص
                  fontWeight: FontWeight.bold, // النص عريض
                  color: Colors.white, // لون النص
                  fontFamily: 'League Spartan',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Clear the previous quiz and navigate to the home page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPass ? Colors.green : Colors.red, // لون الزر
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // حواف الزر
                ),
              ),
              child: const Text(
                'Back To Home',
                style: TextStyle(
                  fontSize: 20, // حجم النص
                  fontWeight: FontWeight.bold, // النص عريض
                  color: Colors.white, // لون النص
                  fontFamily: 'League Spartan',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}