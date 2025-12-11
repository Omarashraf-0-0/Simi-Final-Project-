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

  // Variables to hold fetched courses and lectures
  List<String> courses = [];
  List<String> coursesIndex = [];
  List<Map<String, String>> lectures = []; // List of lectures with their URLs
  Set<int> selectedLectures = {}; // Selected lecture indices (0-based)
  bool isLoading = true; // To handle loading state
  bool isGenerating = false; // For the generating state
  
  // Consistent font size for all input fields
  final double inputFontSize = 16.0;

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

    // Validate that at least one lecture is selected
    if (selectedLectures.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please select at least one lecture."),
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

    // Convert selected lectures to sorted list (1-based for server)
    List<int> selectedLecturesList = selectedLectures.map((i) => i + 1).toList()..sort();
    int lectureStart = selectedLecturesList.first;
    int lectureEnd = selectedLecturesList.last;

    // Prepare data to send to the server
    Map<String, dynamic> requestData = {
      'course_name': selectedCourse!.replaceAll(' ', ''),
      'co_id': selectedCourseId,
      'lecture_start': lectureStart,
      'lecture_end': lectureEnd,
      'selected_lectures': selectedLecturesList,
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
        Navigator.push(
          context,
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
                        style: TextStyle(
                          color: blue2, // Set the placeholder text color to blue
                          fontSize: inputFontSize,
                          fontFamily: 'League Spartan',
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
                    items: courses.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: blue2, // Changed from light blue to normal blue
                            fontSize: inputFontSize,
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
                        selectedLectures.clear(); // Clear selected lectures
                      });
                      // Fetch lectures for the selected course
                      getLectures(selectedCourseId!);
                    },
                  ),
                  const SizedBox(height: 30),
                  // Display Lectures
                  if (lectures.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Lectures',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        // Select All / Deselect All button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedLectures.length == lectures.length) {
                                selectedLectures.clear();
                              } else {
                                selectedLectures = Set.from(List.generate(lectures.length, (i) => i));
                              }
                            });
                          },
                          child: Text(
                            selectedLectures.length == lectures.length ? 'Deselect All' : 'Select All',
                            style: TextStyle(
                              fontSize: inputFontSize,
                              fontFamily: 'League Spartan',
                              color: blue2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Chip-based lecture selection
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(lectures.length, (index) {
                          bool isSelected = selectedLectures.contains(index);
                          return FilterChip(
                            label: Text(
                              'Lecture ${index + 1}',
                              style: TextStyle(
                                fontSize: inputFontSize,
                                fontFamily: 'League Spartan',
                                color: isSelected ? white : blue2,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedLectures.add(index);
                                } else {
                                  selectedLectures.remove(index);
                                }
                              });
                            },
                            selectedColor: blue2,
                            backgroundColor: white,
                            checkmarkColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: blue2),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Selected count indicator
                    Text(
                      '${selectedLectures.length} of ${lectures.length} lectures selected',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'League Spartan',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
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
                      labelStyle: TextStyle(
                        color: blue2, // Set the label text color to blue
                        fontSize: inputFontSize,
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
                      fontSize: inputFontSize,
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
                            labelStyle: TextStyle(
                              color: blue2,
                              fontSize: inputFontSize,
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
                            fontSize: inputFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                            color: Colors.black,
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
                              fontSize: inputFontSize,
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
                            fontSize: inputFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                            color: Colors.black,
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
