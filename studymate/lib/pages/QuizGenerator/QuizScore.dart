// QuizScore.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/XPChangePopup.dart';
import 'ViewAnswer.dart';

class QuizScore extends StatefulWidget {
  final int score;
  final int total;
  final List<int> userAnswers;
  final List<Map<String, dynamic>> questions;
  final int xpChange;
  final String xpMessage;

  const QuizScore({
    super.key,
    required this.score,
    required this.total,
    required this.userAnswers,
    required this.questions,
    required this.xpChange,
    required this.xpMessage,
  });

  @override
  State<QuizScore> createState() => _QuizScoreState();
}

class _QuizScoreState extends State<QuizScore> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showXPChangePopup(context, widget.xpChange, widget.xpMessage);
    });
  }

  void showXPChangePopup(BuildContext context, int xpChange, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the popup by tapping outside
      builder: (BuildContext context) {
        return XPChangePopup(
          xpChange: xpChange,
          message: message,
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Prevent back button
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.total;
    bool isPass = percentage >= 0.5;

    return WillPopScope(
      onWillPop: _onWillPop, // Disable back navigation
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
              SizedBox(
                height: 20,
              ),
              Text(
                'Your Score is',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'League Spartan',
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 120,
              ),
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