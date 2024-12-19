import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/QuizGenerator/QuizScore.dart';
import 'package:google_fonts/google_fonts.dart';


class QuizScore extends StatefulWidget {
  final int score; // النتيجة
  final int total; // الإجمالي

  const QuizScore({super.key, required this.score, required this.total});

  @override
  State<QuizScore> createState() => _QuizScoreState();
}

class _QuizScoreState extends State<QuizScore> {
  @override
  Widget build(BuildContext context) {
    // حساب النسبة المئوية
    double percentage = widget.score / widget.total * 100;

    // تحديد إذا كان ناجحًا أم لا
    bool isPass = percentage >= 50;

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
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPass
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  'Your Score\n${widget.score}/${widget.total}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPass ? Colors.green : Colors.red,
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPass
                  ? 'Congratulations!\nYou Nailed It! Keep Up The Amazing Work'
                  : 'Oops!\nBetter Luck Next Time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPass ? Colors.green : Colors.red,
                fontFamily: 'League Spartan',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizHome()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165D96), // لون الزر
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
                // الرجوع للصفحة الرئيسية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizHome()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165D96), // لون الزر
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
          ],
        ),
      ),
    );
  }
}
