// QuizOptions.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
import 'package:hive/hive.dart';
import 'Quiz.dart'; // Import the Quiz screen
import 'package:studymate/theme/app_constants.dart';

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
  bool isGenerating = false; // For the generating state

  @override
  void initState() {
    super.initState();
    takecourses(); // Fetch courses when the widget initializes
  }

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

  void validateQuestions() async {
    // Parse inputs safely, default to -1 to capture invalid inputs
    int totalQuestions = int.tryParse(questionsController.text) ?? -1;
    int mcqCount = int.tryParse(mcqController.text) ?? -1;
    int tfCount = int.tryParse(tfController.text) ?? -1;
    int lectureFrom = int.tryParse(lectureFromController.text) ?? -1;
    int lectureTo = int.tryParse(lectureToController.text) ?? -1;

    // Check if a course is selected
    if (selectedCourse == null) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please select a course."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if lectures are available
    if (lectures.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content:
                const Text("No lectures available for the selected course."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validate lecture range inputs
    if (lectureFrom <= 0 || lectureTo <= 0 || lectureFrom > lectureTo) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please enter a valid lecture range."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if lecture numbers exceed available lectures
    if (lectureFrom > lectures.length || lectureTo > lectures.length) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(
                "Lecture numbers exceed available lectures. Please select between 1 and ${lectures.length}."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validate question numbers
    if (totalQuestions <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Total number of questions must be a positive integer."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (mcqCount < 0 || tfCount < 0) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Number of MCQ and T/F questions cannot be negative."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (mcqCount + tfCount != totalQuestions) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "The total number of MCQs and T/F questions must equal the number of questions."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // All validations passed, set isGenerating to true
    setState(() {
      isGenerating = true;
      print('isGenerating set to true');
    });

    // Prepare data to send to the server
    Map<String, dynamic> requestData = {
      'course_name': selectedCourse!.replaceAll(' ', ''),
      'co_id': selectedCourseId,
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
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          isGenerating = false;
          print('isGenerating set to false');
        });

        // Navigate to the Quiz screen and pass the quiz data and co_id
        Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(
            builder: (context) => Quiz(
              quizData: jsonResponse,
              totalQuestions: totalQuestions,
              mcqCount: mcqCount,
              tfCount: tfCount,
              coId: selectedCourseId!,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // Handle server-side validation errors
        setState(() {
          isGenerating = false;
          print('isGenerating set to false');
        });
        var jsonResponse = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(jsonResponse['error'] ?? 'Unknown error occurred.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isGenerating = false;
          print('isGenerating set to false');
        });
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(
                  'An unexpected server error occurred. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        isGenerating = false;
        print('isGenerating set to false');
      });
      print('Error: $e');
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(
                'An error occurred while generating the quiz: $e. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Set background color to white
      appBar: AppConstants.buildAppBar(
        title: 'Make Your Quiz!',
      ),
      body: isLoading || isGenerating
          ? AppConstants.buildLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Select Your Course
                  Text(
                    'Select Your Course',
                    style: AppConstants.cardTitle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    isExpanded: true, // Ensures the dropdown fills the width
                    hint: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Course',
                        style: AppConstants.bodyText.copyWith(
                          color: AppConstants.primaryBlueDark,
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 17),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items: courses.asMap().entries.map((entry) {
                      String value = entry.value;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: AppConstants.bodyText.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundLight,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.builder(
                        itemCount: lectures.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.book,
                                color: AppConstants.primaryBlueDark),
                            title: Text(
                              lectures[index]['name']!,
                              style: AppConstants.bodyText.copyWith(
                                color: AppConstants.textPrimary,
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
                    style: AppConstants.cardTitle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Lecture Range 'From' and 'To' boxes
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lectureFromController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'From',
                            labelStyle: AppConstants.bodyText.copyWith(
                              color: AppConstants.primaryBlueDark,
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
                            color: Colors
                                .black, // User input text color set to black
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
                            labelStyle: AppConstants.bodyText.copyWith(
                              color: AppConstants.primaryBlueDark,
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
                            color: Colors
                                .black, // User input text color set to black
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Section: Questions Number
                  Text(
                    'Questions Number',
                    style: AppConstants.cardTitle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: questionsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          'Total Questions', // Changed from hintText to labelText
                      labelStyle: AppConstants.bodyText.copyWith(
                        color: AppConstants.primaryBlueDark,
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
                    style: AppConstants.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Section: Questions Type
                  Text(
                    'Questions Type',
                    style: AppConstants.cardTitle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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
                            labelStyle: AppConstants.bodyText.copyWith(
                              color: AppConstants.primaryBlueDark,
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
                            color: Colors
                                .black, // User input text color set to black
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
                            labelStyle: AppConstants.bodyText.copyWith(
                              color: AppConstants.primaryBlueDark,
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
                            color: Colors
                                .black, // User input text color set to black
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
                        backgroundColor: AppConstants.primaryBlueDark,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Generate Quiz',
                        style: AppConstants.subtitle.copyWith(
                          fontSize: 22,
                          color: AppConstants.textOnPrimary,
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
