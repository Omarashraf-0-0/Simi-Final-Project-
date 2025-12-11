import 'package:flutter/material.dart';
import 'package:studymate/pages/QuizGenerator/QuizOptions.dart';
import 'package:studymate/theme/app_constants.dart';

class QuizHome extends StatefulWidget {
  const QuizHome({super.key});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Set background color to white for a clean look
      appBar: AppConstants.buildAppBar(
        title: 'Quiz Generator',
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Adjusted image for better scaling
              Image.asset(
                'assets/img/QuizTime.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              // Simplified text styling and alignment
              Text(
                'Ready To Challenge Yourself?\nLet\'s Create Your Quiz!',
                textAlign: TextAlign.center,
                style: AppConstants.sectionHeader.copyWith(
                  fontSize: 26,
                  color: AppConstants.primaryBlueDark,
                ),
              ),
              SizedBox(height: 60),
              // Styled button to match branding
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizOptions()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlueDark,
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXXL + 2,
                        vertical: AppConstants.spacingM + 3),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXL + 6),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Start The Fun!',
                    style: AppConstants.sectionHeader.copyWith(
                      color: AppConstants.textOnPrimary,
                      fontWeight: AppConstants.fontWeightBold,
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
