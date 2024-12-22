import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/HomePage/HomePage.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/QuizGenerator/Quiz.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizOptions extends StatefulWidget {
  const QuizOptions({super.key});

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions> {
  String? selectedCourse;
  int _currentSliderValue = 1;
  TextEditingController questionsController = TextEditingController();
  TextEditingController mcqController = TextEditingController();
  TextEditingController tfController = TextEditingController();

  void validateQuestions() {
    int totalQuestions = int.tryParse(questionsController.text) ?? 0;
    int mcqCount = int.tryParse(mcqController.text) ?? 0;
    int tfCount = int.tryParse(tfController.text) ?? 0;

    if (mcqCount + tfCount != totalQuestions) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("The total number of MCQs and T/F questions must equal the number of questions."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Pass data to Quiz Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Quiz(
          totalQuestions: totalQuestions,
          mcqCount: mcqCount,
          tfCount: tfCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // Blue color for the AppBar
        title: Text(
          'Make Your Quiz!',
          style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true, // Center the title in the AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // make every row in the column be at the center of the column
            SizedBox(height: 20),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Your Course',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCourse,
                    decoration: InputDecoration(
                      labelText: 'Choose Course',
                      prefixIcon:
                          selectedCourse == null ? Icon(Icons.book) : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFF165D96)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color:  Color(0xFF165D96), width: 2.0),
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Field 1',
                      'Field 2',
                      'Field 3',
                      'Field 4',
                      'Field 5',
                      'Field 6'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            if (selectedCourse != value)
                              Icon(Icons.circle,
                                  size: 16, color: Color(0xFF165D96)), // Small icon
                            if (selectedCourse != value) SizedBox(width: 10),
                            Text(value,
                                style: TextStyle(
                                    color: Color(0xFF165D96))), // Light gray text
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCourse = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lecture Range',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                    color: Color(0xFF165D96),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 75,
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10), // Center the text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:  Color(0xFF165D96),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Text(
                  'To',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                    color: Color(0xFF165D96),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 75,
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10), // Center the text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:  Color(0xFF165D96),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Questions Number',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Num',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                    color: Color(0xFF165D96),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 75,
                  height: 40,
                  child: TextField(
                    controller: questionsController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10), // Center the text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:  Color(0xFF165D96),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Questions Type',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MCQ',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                    color: Color(0xFF165D96),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 75,
                  height: 40,
                  child: TextField(
                    controller: mcqController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10), // Center the text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:  Color(0xFF165D96),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30),
                Text(
                  'T/F',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                    color: Color(0xFF165D96),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 75,
                  height: 40,
                  child: TextField(
                    controller: tfController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10), // Center the text vertically
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:  Color(0xFF165D96),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                onPressed: validateQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF165D96), // Button color
                  padding: EdgeInsets.symmetric(
                      horizontal: 70, vertical: 10), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button radius
                  ),
                ),
                child: Text(
                  'Generate Quiz',
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
          ],
        ),
      ),
    );
  }
}