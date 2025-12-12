// QuizOptions.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:hive_flutter/hive_flutter.dart'; // For Hive storage
import 'package:hive/hive.dart';
import 'Quiz.dart'; // Import the Quiz screen

class QuizOptions extends StatefulWidget {
  const QuizOptions({super.key});

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions>
    with SingleTickerProviderStateMixin {
  // Define your branding colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color white = const Color(0xFFFFFFFF);

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Consistent font size for all input fields
  final double inputFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    takecourses(); // Fetch courses when the widget initializes
  }

  @override
  void dispose() {
    _animationController.dispose();
    questionsController.dispose();
    mcqController.dispose();
    tfController.dispose();
    super.dispose();
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
    List<int> selectedLecturesList = selectedLectures.map((i) => i + 1).toList()
      ..sort();
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
      backgroundColor: backgroundColor,
      body: isLoading || isGenerating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          accentColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isGenerating ? 'Generating Quiz...' : 'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Modern Gradient AppBar
                SliverAppBar(
                  expandedHeight: 160,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: primaryColor,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, secondaryColor, accentColor],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Quiz Options',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Customize your quiz',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // Course Selection Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.1),
                                        accentColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          color: primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Select Your Course',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCourse,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Choose Course',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      floatingLabelStyle: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.book_rounded,
                                        color: primaryColor,
                                      ),
                                      filled: true,
                                      fillColor: primaryColor.withOpacity(0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: primaryColor.withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: courses.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            value,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedCourse = newValue;
                                        int index = courses.indexOf(newValue!);
                                        selectedCourseId = coursesIndex[index];
                                        lectures = [];
                                        selectedLectures.clear();
                                      });
                                      getLectures(selectedCourseId!);
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: primaryColor,
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Lectures Section
                          if (lectures.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor.withOpacity(0.1),
                                          accentColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: accentColor
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.list_alt_rounded,
                                                color: accentColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Select Lectures',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if (selectedLectures.length ==
                                                  lectures.length) {
                                                selectedLectures.clear();
                                              } else {
                                                selectedLectures = Set.from(
                                                    List.generate(
                                                        lectures.length,
                                                        (i) => i));
                                              }
                                            });
                                          },
                                          child: Text(
                                            selectedLectures.length ==
                                                    lectures.length
                                                ? 'Deselect All'
                                                : 'Select All',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                accentColor.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color:
                                                  accentColor.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: List.generate(
                                                lectures.length, (index) {
                                              bool isSelected = selectedLectures
                                                  .contains(index);
                                              return FilterChip(
                                                label: Text(
                                                  'Lecture ${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? white
                                                        : accentColor,
                                                  ),
                                                ),
                                                selected: isSelected,
                                                onSelected: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      selectedLectures
                                                          .add(index);
                                                    } else {
                                                      selectedLectures
                                                          .remove(index);
                                                    }
                                                  });
                                                },
                                                selectedColor: accentColor,
                                                backgroundColor: white,
                                                checkmarkColor: white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: isSelected
                                                        ? accentColor
                                                        : accentColor
                                                            .withOpacity(0.3),
                                                    width: 2,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              size: 18,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${selectedLectures.length} of ${lectures.length} lectures selected',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          // Questions Configuration Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        secondaryColor.withOpacity(0.1),
                                        secondaryColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              secondaryColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.format_list_numbered_rounded,
                                          color: secondaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Configure Questions',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      // Total Questions
                                      TextField(
                                        controller: questionsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Total Questions',
                                          labelStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          floatingLabelStyle: TextStyle(
                                            color: secondaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.numbers_rounded,
                                            color: secondaryColor,
                                          ),
                                          filled: true,
                                          fillColor:
                                              secondaryColor.withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: secondaryColor
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: secondaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // MCQ and T/F
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: mcqController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'MCQ',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                floatingLabelStyle: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  color: primaryColor,
                                                ),
                                                filled: true,
                                                fillColor: primaryColor
                                                    .withOpacity(0.05),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: primaryColor
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              controller: tfController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'T/F',
                                                labelStyle: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                floatingLabelStyle: TextStyle(
                                                  color: accentColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.toggle_on_rounded,
                                                  color: accentColor,
                                                ),
                                                filled: true,
                                                fillColor: accentColor
                                                    .withOpacity(0.05),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: accentColor
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: accentColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          // Generate Button
                          Container(
                            width: double.infinity,
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, accentColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: validateQuestions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Generate Quiz',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
