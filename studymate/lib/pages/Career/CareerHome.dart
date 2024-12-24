// Import necessary packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CareerJob.dart'; // Import the CareerJob page
import 'CV.dart';

class CareerHome extends StatefulWidget {
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
      appBar: AppBar(
        title: Text(
          'Career Options',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF165D96),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big picture at the top
            Container(
              height: size.height * 0.33,
              width: double.infinity,
              child: Image.asset(
                'lib/assets/img/career.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Prompt text with 'career path' in blue
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'Choose your '),
                      TextSpan(
                        text: 'career path',
                        style: TextStyle(
                          color: Colors.blue, // Set 'career path' to blue
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                              ? Colors.blue
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circle with light blue color
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            child: Image.asset(
                              'lib/assets/img/career2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Find a Job',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Search and apply\nfor jobs',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                            ),
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
                              ? Colors.blue
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circle with light blue color
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            child: Image.asset(
                              'lib/assets/img/cv2.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Create a CV',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Build your\nprofessional CV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                            ),
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
                          MaterialPageRoute(
                              builder: (context) => CareerJob()),
                        );
                      } else if (selectedBox == 'Create a CV') {
                        // Navigate to CreateCVPage (implement this page)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CV()),
                        );
                      }
                    }
                  : null, // Disable button if no selection
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165D96),
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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