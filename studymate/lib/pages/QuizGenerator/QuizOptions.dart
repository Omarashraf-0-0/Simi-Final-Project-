// QuizOptions.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Quiz.dart'; // Import the Quiz screen

class QuizOptions extends StatefulWidget {
  const QuizOptions({super.key});

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions> {
  // Define your branding colors
  final Color blue1 = Color(0xFF1c74bb);
  final Color blue2 = Color(0xFF165d96);
  final Color cyan1 = Color(0xFF18bebc);
  final Color cyan2 = Color(0xFF139896);
  final Color black = Color(0xFF000000);
  final Color white = Color(0xFFFFFFFF);

  String? selectedCourse;
  String? selectedCourseId;
  TextEditingController questionsController = TextEditingController();
  TextEditingController mcqController = TextEditingController();
  TextEditingController tfController = TextEditingController();
  TextEditingController lectureFromController = TextEditingController();
  TextEditingController lectureToController = TextEditingController();

  // Variables to hold fetched courses and lectures
  List<String> courses = [];
  List<String> coursesIndex = [];
  List<Map<String, String>> lectures = []; // List of lectures with their URLs
  bool isLoading = true; // To handle loading state
  bool isGenerating = false; // For the generating state

  @override
  void initState() {
    super.initState();
    takecourses(); // Fetch courses when the widget initializes
  }

  Future<void> takecourses() async {
    const url = 'https://alyibrahim.pythonanywhere.com/TakeCourses'; // Server URL
    final username = Hive.box('userBox').get('username');
    final Map<String, dynamic> requestBody = {
      'username': username,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      setState(() {
        courses = jsonResponse['courses'].cast<String>();
        coursesIndex = (jsonResponse['CourseID'] as List)
            .map((item) => item['COId'].toString())
            .toList();
        isLoading = false;
      });
    } else {
      print('Request failed with status: ${response.body}.');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getLectures(String courseId) async {
    const url = 'https://alyibrahim.pythonanywhere.com/CourseContent'; // Corrected URL
    final username = Hive.box('userBox').get('username');
    final Map<String, dynamic> requestBody = {
      'courseIdx': courseId,
      'username': username,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      setState(() {
        lectures = [];
        if (jsonResponse['subInfo'] != null) {
          for (var resource in jsonResponse['subInfo']) {
            if (resource['RCat'] == 'L') {
              lectures.add({
                'name': resource['RName'],
                'url': resource['RFileURL'],
              });
            }
          }
        }
      });
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }

  void validateQuestions() async {
    setState(() {
      isGenerating = true;
    });

    int totalQuestions = int.tryParse(questionsController.text) ?? 0;
    int mcqCount = int.tryParse(mcqController.text) ?? 0;
    int tfCount = int.tryParse(tfController.text) ?? 0;
    int lectureFrom = int.tryParse(lectureFromController.text) ?? 1;
    int lectureTo = int.tryParse(lectureToController.text) ?? lectures.length;

    if (mcqCount + tfCount != totalQuestions) {
      setState(() {
        isGenerating = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text(
              "The total number of MCQs and T/F questions must equal the number of questions."),
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

    if (selectedCourse == null) {
      setState(() {
        isGenerating = false;
      });
      print('No course selected.');
      return;
    }

    // Prepare data to send to the server
    Map<String, dynamic> requestData = {
      'course_name': selectedCourse!.replaceAll(' ', ''),
      'co_id': selectedCourseId, // Include co_id
      'lecture_start': lectureFrom,
      'lecture_end': lectureTo,
      'number_of_questions': totalQuestions,
      'num_mcq': mcqCount,
      'num_true_false': tfCount,
    };

    // Send data to server
    try {
      final response = await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/generate_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Successfully received JSON response from server
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          isGenerating = false;
        });

        // Navigate to the Quiz screen and pass the quiz data and co_id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Quiz(
              quizData: jsonResponse, // Pass the quiz data
              totalQuestions: totalQuestions,
              mcqCount: mcqCount,
              tfCount: tfCount,
              coId: selectedCourseId!, // Pass the co_id
            ),
          ),
        );
      } else {
        setState(() {
          isGenerating = false;
        });
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Show error message if needed
      }
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      print('Error: $e');
      // Show error message if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white, // Set background color to white
      appBar: AppBar(
        title: Text(
          'Make Your Quiz!',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        backgroundColor: blue2,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading || isGenerating
          ? Center(
              child: CircularProgressIndicator(
                color: blue2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Select Your Course
                  Text(
                    'Select Your Course',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 17),
                      hintText: 'Choose Course',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'League Spartan',
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items: courses.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String value = entry.value;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: black,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCourse = newValue;
                        int index = courses.indexOf(newValue!);
                        selectedCourseId = coursesIndex[index];
                        lectures = []; // Clear previous lectures
                        lectureFromController.clear();
                        lectureToController.clear();
                      });
                      // Fetch lectures for the selected course
                      getLectures(selectedCourseId!);
                    },
                  ),
                  const SizedBox(height: 30),
                  // Display Lectures
                  if (lectures.isNotEmpty) ...[
                    Text(
                      'Lectures (${lectures.length}):',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.builder(
                        itemCount: lectures.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.book, color: blue2),
                            title: Text(
                              lectures[index]['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'League Spartan',
                                color: black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  // Section: Lecture Range
                  Text(
                    'Lecture Range',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lectureFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'From',
                            labelStyle: TextStyle(
                              color: blue2,
                              fontFamily: 'League Spartan',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: lectureToController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'To',
                            labelStyle: TextStyle(
                              color: blue2,
                              fontFamily: 'League Spartan',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Section: Questions Number
                  Text(
                    'Questions Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: questionsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter total number of questions',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'League Spartan',
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Section: Questions Type
                  Text(
                    'Questions Type',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: mcqController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'MCQ',
                            labelStyle: TextStyle(
                              color: blue2,
                              fontFamily: 'League Spartan',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: tfController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'T/F',
                            labelStyle: TextStyle(
                              color: blue2,
                              fontFamily: 'League Spartan',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Generate Quiz Button
                  Center(
                    child: ElevatedButton(
                      onPressed: validateQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Generate Quiz',
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
    );
  }
}