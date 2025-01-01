// QuizScore.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'ViewAnswer.dart'; // Import the ViewAnswer screen

class QuizScore extends StatefulWidget {
  final int score;
  final int total;
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
  Future<bool> _onWillPop() async {
    bool shouldLeave = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Are you sure?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "You won't be able to see the score again.",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text(
              "No",
              style: TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate to Home Page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Yes",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return false; // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.total;
    bool isPass = percentage >= 0.5;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          backgroundColor: const Color(0xFF165D96),
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
              SizedBox(height: 20),
              Text(
                'Your Score is',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'League Spartan',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 120),
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
              SizedBox(height: 20),
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
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ViewAnswer screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewAnswer(
                        questions: widget.questions,
                        userAnswers: widget.userAnswers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPass ? Colors.green : Colors.red, // Button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button corners
                  ),
                ),
                child: const Text(
                  'View Answers',
                  style: TextStyle(
                    fontSize: 20, // Text size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the home page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Homepage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPass ? Colors.green : Colors.red, // Button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button corners
                  ),
                ),
                child: const Text(
                  'Back To Home',
                  style: TextStyle(
                    fontSize: 20, // Text size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                    fontFamily: 'League Spartan',
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}