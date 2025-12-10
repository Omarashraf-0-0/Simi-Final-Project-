// Import necessary packages
import 'package:flutter/material.dart';
import 'CareerJob.dart'; // Import the CareerJob page
import 'CV.dart';
import '../../theme/app_constants.dart';

class CareerHome extends StatefulWidget {
  const CareerHome({super.key});

  @override
  _CareerHomeState createState() => _CareerHomeState();
}

class _CareerHomeState extends State<CareerHome> {
  String? selectedBox; // To keep track of the selected box

  @override
  Widget build(BuildContext context) {
    // Get device screen size
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppConstants.buildAppBar(
        title: 'Career Options',
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big picture at the top
            SizedBox(
              height: size.height * 0.33,
              width: double.infinity,
              child: Image.asset(
                'assets/img/career.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: AppConstants.spacingL),
            // Prompt text with 'career path' in blue
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: AppConstants.cardTitle.copyWith(
                      color: AppConstants.textPrimary,
                    ),
                    children: [
                      TextSpan(text: 'Choose your '),
                      TextSpan(
                        text: 'career path',
                        style: TextStyle(
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingL),
            // Two boxes beside each other
            Row(
              children: [
                // First box: Find a Job
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBox = 'Find a Job';
                      });
                    },
                    child: Container(
                      height: 270, // Set a fixed height
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedBox == 'Find a Job'
                              ? AppConstants.primaryBlue
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circle with light blue color
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            child: Image.asset(
                              'assets/img/career2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingM),
                          Text(
                            'Find a Job',
                            style: AppConstants.subtitle.copyWith(
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'Search and apply\nfor jobs',
                            textAlign: TextAlign.center,
                            style: AppConstants.bodyText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Second box: Create a CV
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBox = 'Create a CV';
                      });
                    },
                    child: Container(
                      height: 270, // Set a fixed height
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedBox == 'Create a CV'
                              ? AppConstants.primaryBlue
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circle with light blue color
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            child: Image.asset(
                              'assets/img/cv2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingM),
                          Text(
                            'Create a CV',
                            style: AppConstants.subtitle.copyWith(
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'Build your\nprofessional CV',
                            textAlign: TextAlign.center,
                            style: AppConstants.bodyText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Continue button
            ElevatedButton(
              onPressed: selectedBox != null
                  ? () {
                      // Handle navigation based on selection
                      if (selectedBox == 'Find a Job') {
                        // Navigate to CareerJob page directly without using named routes
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CareerJob()),
                        );
                      } else if (selectedBox == 'Create a CV') {
                        // Navigate to CreateCVPage (implement this page)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CV()),
                        );
                      }
                    }
                  : null, // Disable button if no selection
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlueDark,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      AppConstants.spacingXXL + AppConstants.spacingXL + 6,
                  vertical: AppConstants.spacingM - 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: Text(
                'Continue',
                style: AppConstants.pageTitle.copyWith(
                  fontSize: AppConstants.fontSizeXL + 2,
                  color: AppConstants.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
