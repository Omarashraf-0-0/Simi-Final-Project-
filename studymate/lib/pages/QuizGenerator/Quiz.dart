import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/QuizGenerator/QuizScore.dart';
import 'package:google_fonts/google_fonts.dart';

class Quiz extends StatefulWidget {
  final int totalQuestions;
  final int mcqCount;
  final int tfCount;

  const Quiz({
    super.key,
    required this.totalQuestions,
    required this.mcqCount,
    required this.tfCount,
  });

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int currentQuestion = 0;
  int correctAnswers = 0;
  List<int> userAnswers = List.filled(0, -1, growable: true); // Store the selected options
  List<bool> isCorrectList = []; // Track correctness of answers
  late int totalSecondsRemaining; // Total time for all questions
  Timer? timer;

  // List of questions and answers
  final List<Map<String, dynamic>> baseQuestions = [
    {
      "question": "Men A5wl wa7d fe el 23dh",
      "options": ["Salah", "Abo 3li el Kabeer", "Sala eldn", "Zambada"],
      "selectedOption": -1, // Initially no option selected
      "correctOption": 0, // Correct option index
    },
    {
      "question": "Zb 3b3alem kam cm?",
      "options": ["69cm", "99999999cm", "LONG_LONG_MAX", "Infinity"],
      "selectedOption": -1,
      "correctOption": 0,
    },
    {
      "question": "What is the capital of Germany?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"],
      "selectedOption": -1,
      "correctOption": 0,
    },
    {
      "question": "What is the capital of Egypt?",
      "options": ["el Mahmodyh", "Cairo", "Kima", "Rome"],
      "selectedOption": -1,
      "correctOption": 0,
    },
  ];

  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    totalSecondsRemaining = 60 * widget.totalQuestions; // Total time for all questions
    questions = List.generate(widget.totalQuestions, (index) => baseQuestions[index % baseQuestions.length]);
    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSecondsRemaining > 0) {
        setState(() {
          totalSecondsRemaining--;
        });
      } else {
        // Time's up, submit the quiz
        submitQuiz();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void submitQuiz() {
    stopTimer();
    for (int i = 0; i < questions.length; i++) {
      if (questions[i]["selectedOption"] == questions[i]["correctOption"]) {
        correctAnswers++;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScore(
          score: correctAnswers,
          total: widget.totalQuestions,
          userAnswers: userAnswers,
          questions: questions,
        ),
      ),
    );
  }

  // Select an option
  void selectOption(int index) {
    setState(() {
      questions[currentQuestion]["selectedOption"] = index;
      if (userAnswers.length > currentQuestion) {
        userAnswers[currentQuestion] = index;
      } else {
        userAnswers.add(index);
      }
    });
  }

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // Blue color for the AppBar
        title: Text(
          'Quiz',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Center the title in the AppBar
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.watch_later,
                  color: Color(0xFF165D96), // Watch icon color
                  size: 24,
                ),
                SizedBox(width: 5), // Space between the icon and the text
                Text(
                  '${totalSecondsRemaining ~/ 60}:${(totalSecondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // Make the timer text bold
                    color: Color(0xFF165D96), // Timer text color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            // Question Navigator Slider
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Add margin from right and left
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentQuestion = index;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width:
                                50, // Ensure the width is equal to the height to make it a circle
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: currentQuestion == index
                                  ? Color(0xFF165D96)
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle, // Set the shape to circle
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontFamily: 'League Spartan',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  4), // Space between the circle and the line
                          Container(
                            width: 50,
                            height: 2,
                            color: currentQuestion == index
                                ? Color(0xFF165D96)
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                questions[currentQuestion]["question"],
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Options
            ...List.generate(
              questions[currentQuestion]["options"].length,
              (index) {
                bool isSelected =
                    questions[currentQuestion]["selectedOption"] == index;

                return GestureDetector(
                  onTap: () => selectOption(index),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Remove background color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF165D96)
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          questions[currentQuestion]["options"][index],
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Make the options bold
                            color: isSelected ? Color(0xFF165D96) : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Navigation Buttons (Back, Submit, Next)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: currentQuestion > 0 ? previousQuestion : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion > 0
                            ? Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: submitQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF165D96), // Button color
                      padding: EdgeInsets.symmetric(
                          horizontal: 70, vertical: 10), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Button radius
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 25, // Button text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),

                  // Next Button
                  GestureDetector(
                    onTap: currentQuestion < questions.length - 1
                        ? nextQuestion
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion < questions.length - 1
                            ? Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}