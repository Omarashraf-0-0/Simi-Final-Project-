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

  Future<void> takecourses() async {
    const url =
        'https://alyibrahim.pythonanywhere.com/TakeCourses'; // Server URL
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
    const url =
        'https://alyibrahim.pythonanywhere.com/CourseContent'; // Corrected URL
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

  @override
  void initState() {
    super.initState();
    takecourses(); // Fetch courses when the widget initializes
  }

void validateQuestions() async {
  int totalQuestions = int.tryParse(questionsController.text) ?? 0;
  int mcqCount = int.tryParse(mcqController.text) ?? 0;
  int tfCount = int.tryParse(tfController.text) ?? 0;
  int lectureFrom = int.tryParse(lectureFromController.text) ?? 1;
  int lectureTo = int.tryParse(lectureToController.text) ?? lectures.length;

  if (mcqCount + tfCount != totalQuestions) {
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
    print('No course selected.');
    return;
  }

  // Prepare data to send to the server
  Map<String, dynamic> requestData = {
    'course_name': selectedCourse!.replaceAll(' ', ''),
    'co_id': selectedCourseId,  // Include co_id
    'lecture_start': lectureFrom,
    'lecture_end': lectureTo,
    'number_of_questions': totalQuestions,
    'num_mcq': mcqCount,
    'num_true_false': tfCount,
  };

  print('Request Data:');
  print(jsonEncode(requestData));

  // Send data to server
  final response = await http.post(
    Uri.parse('https://alyibrahim.pythonanywhere.com/generate_quiz'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 200) {
    // Successfully received JSON response from server
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse); // For testing purposes

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
    print('Server error: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Make Your Quiz!',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCourse,
                          decoration: InputDecoration(
                            labelText: 'Choose Course',
                            prefixIcon: selectedCourse == null
                                ? const Icon(Icons.book)
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF165D96)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: courses.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String value = entry.value;
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  if (selectedCourse != value)
                                    const Icon(Icons.circle,
                                        size: 16, color: Color(0xFF165D96)),
                                  if (selectedCourse != value)
                                    const SizedBox(width: 10),
                                  Text(value,
                                      style: const TextStyle(
                                          color: Color(0xFF165D96))),
                                ],
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Display Lectures
                  if (lectures.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Lectures (${lectures.length}):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150, // Adjust the height as needed
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: lectures.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              lectures[index]['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily:
                                    GoogleFonts.leagueSpartan().fontFamily,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  // Lecture Range Selection
                  Row(
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: const Color(0xFF165D96),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 75,
                        height: 40,
                        child: TextField(
                          controller: lectureFromController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: const Color(0xFF165D96),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 75,
                        height: 40,
                        child: TextField(
                          controller: lectureToController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Questions Number
                  Row(
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Num',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: const Color(0xFF165D96),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 75,
                        height: 40,
                        child: TextField(
                          controller: questionsController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Questions Type
                  Row(
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MCQ',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: const Color(0xFF165D96),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 75,
                        height: 40,
                        child: TextField(
                          controller: mcqController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        'T/F',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: const Color(0xFF165D96),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 75,
                        height: 40,
                        child: TextField(
                          controller: tfController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF165D96), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Generate Quiz Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: validateQuestions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF165D96),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Generate Quiz',
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
                ],
              ),
            ),
    );
  }
}