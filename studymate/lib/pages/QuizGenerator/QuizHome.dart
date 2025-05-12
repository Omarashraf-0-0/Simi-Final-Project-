import 'package:flutter/material.dart';
import 'package:studymate/pages/QuizGenerator/QuizOptions.dart';

class QuizHome extends StatefulWidget {
  const QuizHome({super.key});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  // Define branding colors
  const Color blue1 = Color(0xFF1c74bb);
  const Color blue2 = Color(0xFF165d96);
  const Color cyan1 = Color(0xFF18bebc);
  const Color cyan2 = Color(0xFF139896);
  const Color black = Color(0xFF000000);
  const Color white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Set background color to white for a clean look
      appBar: AppBar(
        backgroundColor: blue2, // Use branding blue color
        title: const Text(
          'Quiz Generator',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Remove shadow for a flat design
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Adjusted image for better scaling
              Image.asset(
                'lib/assets/img/QuizTime.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              // Simplified text styling and alignment
              const Text(
                'Ready To Challenge Yourself?\nLet\'s Create Your Quiz!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'League Spartan',
                  color: blue2,
                ),
              ),
              const SizedBox(height: 60),
              // Styled button to match branding
              Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizOptions()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue2, // Use branding blue color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 5, // Add slight shadow
                ),
                child: const Text(
                  'Start The Fun!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: white,
                    fontFamily: 'League Spartan',
                  ),
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