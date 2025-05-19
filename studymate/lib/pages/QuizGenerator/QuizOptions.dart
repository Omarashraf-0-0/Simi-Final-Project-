  // QuizOptions.dart

  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;           // For HTTP requests
  import 'package:hive_flutter/hive_flutter.dart';   // For Hive storage
  import 'package:hive/hive.dart';
  import 'package:path_provider/path_provider.dart';  // For saving PDF locally
  import 'Quiz.dart';                                // Your existing Quiz screen

  class QuizOptions extends StatefulWidget {
    const QuizOptions({super.key});

    @override
    State<QuizOptions> createState() => _QuizOptionsState();
  }

  class _QuizOptionsState extends State<QuizOptions> {
    // --------------------------------------------------------------------------
    // Branding colors
    // --------------------------------------------------------------------------
    final Color blue1 = const Color(0xFF1c74bb);
    final Color blue2 = const Color(0xFF165d96);
    final Color cyan1 = const Color(0xFF18bebc);
    final Color cyan2 = const Color(0xFF139896);
    final Color black = const Color(0xFF000000);
    final Color white = const Color(0xFFFFFFFF);

    // --------------------------------------------------------------------------
    // Role check
    // --------------------------------------------------------------------------
    // userBox.role == 'student' | 'moderator' | 'doctor'
    bool get isDoctor {
      final role = Hive.box('userBox').get('role');
          print('*** DEBUG: isDoctor check => role="$role"');
      return role != null && role.toString().toLowerCase() == 'doctor';
    }

    // --------------------------------------------------------------------------
    // Form state
    // --------------------------------------------------------------------------
    String? selectedCourse;
    String? selectedCourseId;

    // Controllers for text fields
    final TextEditingController questionsController     = TextEditingController();
    final TextEditingController mcqController           = TextEditingController();
    final TextEditingController tfController            = TextEditingController();
    final TextEditingController lectureFromController   = TextEditingController();
    final TextEditingController lectureToController     = TextEditingController();
    final TextEditingController copiesController        = TextEditingController(text: '1');

    // Fetched lists
    List<String> courses        = [];
    List<String> coursesIndex   = [];
    List<Map<String, String>> lectures = [];

    // Loading / generating flags
    bool isLoading    = true;
    bool isGenerating = false;

    @override
    void initState() {
      super.initState();
      _takeCourses();
    }

    // --------------------------------------------------------------------------
    // 1) Fetch available courses from server
    // --------------------------------------------------------------------------
    Future<void> _takeCourses() async {
      const url = 'https://alyibrahim.pythonanywhere.com/TakeCourses';
      final username = Hive.box('userBox').get('username');
      final requestBody = { 'username': username };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          setState(() {
            courses      = List<String>.from(jsonResponse['courses']);
            coursesIndex = (jsonResponse['CourseID'] as List)
                              .map((item) => item['COId'].toString())
                              .toList();
            isLoading = false;
          });
        } else {
          print('TakeCourses failed: ${response.body}');
          setState(() { isLoading = false; });
        }
      } catch (e) {
        print('TakeCourses error: $e');
        setState(() { isLoading = false; });
      }
    }

    // --------------------------------------------------------------------------
    // 2) Fetch lectures for a selected course
    // --------------------------------------------------------------------------
    Future<void> _getLectures(String courseId) async {
      const url = 'https://alyibrahim.pythonanywhere.com/CourseContent';
      final username = Hive.box('userBox').get('username');
      final requestBody = {
        'courseIdx': courseId,
        'username': username,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final List<Map<String, String>> subs = [];

          if (jsonResponse['subInfo'] != null) {
            for (var r in jsonResponse['subInfo']) {
              if (r['RCat'] == 'L') {
                subs.add({
                  'name': r['RName'],
                  'url':  r['RFileURL'],
                });
              }
            }
          }

          setState(() {
            lectures = subs;
          });
        } else {
          print('CourseContent failed: ${response.body}');
        }
      } catch (e) {
        print('CourseContent error: $e');
      }
    }

    // --------------------------------------------------------------------------
    // 3) Universal error dialog
    // --------------------------------------------------------------------------
    void _showError(String msg) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Error"),
          content: Text(msg),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text("OK")),
          ],
        ),
      );
    }

    // --------------------------------------------------------------------------
    // 4) Validate inputs & call the correct endpoint
    // --------------------------------------------------------------------------
    Future<void> validateQuestions() async {
      // Parse all inputs
      final totalQuestions  = int.tryParse(questionsController.text)   ?? -1;
      final mcqCount        = int.tryParse(mcqController.text)       ?? -1;
      final tfCount         = int.tryParse(tfController.text)        ?? -1;
      final lectureFrom     = int.tryParse(lectureFromController.text) ?? -1;
      final lectureTo       = int.tryParse(lectureToController.text)   ?? -1;
      final copies          = int.tryParse(copiesController.text)     ?? 1;

      // 4.1) Common validations
      if (selectedCourse == null) {
        return _showError("Please select a course.");
      }
      if (lectures.isEmpty) {
        return _showError("No lectures available for the selected course.");
      }
      if (lectureFrom <= 0 || lectureTo <= 0 || lectureFrom > lectureTo) {
        return _showError("Please enter a valid lecture range.");
      }
      if (lectureFrom > lectures.length || lectureTo > lectures.length) {
        return _showError(
          "Lecture numbers exceed available lectures. Please select between 1 and ${lectures.length}."
        );
      }
      if (totalQuestions <= 0) {
        return _showError("Total number of questions must be positive.");
      }
      if (mcqCount < 0 || tfCount < 0) {
        return _showError("Number of MCQ and T/F questions cannot be negative.");
      }
      if (mcqCount + tfCount != totalQuestions) {
        return _showError("MCQs + T/F must equal total questions.");
      }

      // 4.2) Doctor‐only validation
      if (isDoctor && copies <= 0) {
        return _showError("Number of copies must be at least 1.");
      }

      // All checks passed
      setState(() { isGenerating = true; });

      // Prepare request
      final endpoint = isDoctor
          ? 'https://alyibrahim.pythonanywhere.com/generate_paper_quiz'
          : 'https://alyibrahim.pythonanywhere.com/generate_quiz';

      final requestData = {
        'course_name':       selectedCourse!.replaceAll(' ', ''),
        'co_id':             selectedCourseId,
        'lecture_start':     lectureFrom,
        'lecture_end':       lectureTo,
        'number_of_questions': totalQuestions,
        'num_mcq':           mcqCount,
        'num_true_false':    tfCount,
      };

      // Doctor adds copies
      if (isDoctor) {
        requestData['copies'] = copies;
      }

      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type':'application/json'},
          body: jsonEncode(requestData),
        );

        setState(() { isGenerating = false; });

        if (response.statusCode == 200) {
          if (isDoctor) {
            // We expect a PDF from /generate_paper_quiz
            final bytes = response.bodyBytes;
            final dir   = await getApplicationDocumentsDirectory();
            final file  = File('${dir.path}/paper_quiz_${DateTime.now().millisecondsSinceEpoch}.pdf');
            await file.writeAsBytes(bytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Saved PDF at ${file.path}"))
            );
          } else {
            // Navigate into in‐app Quiz screen
            final jsonResponse = jsonDecode(response.body);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Quiz(
                  quizData:      jsonResponse,
                  totalQuestions: totalQuestions,
                  mcqCount:      mcqCount,
                  tfCount:       tfCount,
                  coId:          selectedCourseId!,
                ),
              ),
            );
          }
        } else if (response.statusCode == 400) {
          final body = jsonDecode(response.body);
          _showError(body['error'] ?? 'Server validation error.');
        } else {
          _showError('Server error ${response.statusCode}. Please try again.');
          print('Error body: ${response.body}');
        }
      } catch (e) {
        setState(() { isGenerating = false; });
        _showError('Network error: $e');
      }
    }

    // --------------------------------------------------------------------------
    // Build UI
    // --------------------------------------------------------------------------
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Make Your Quiz!',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
          ),
          backgroundColor: blue2,
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading || isGenerating
          ? Center(child: CircularProgressIndicator(color: blue2))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------------
                  // Course selector
                  // -----------------------------------------------------------------
                  const Text('Select Your Course',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    )
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    isExpanded: true,
                    hint: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Choose Course',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          color: Color(0xFF165d96),
                        )
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items: courses.asMap().entries.map((entry) {
                      final idx   = entry.key;
                      final value = entry.value;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                          style: const TextStyle(
                            fontFamily: 'League Spartan',
                          )
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCourse   = newValue;
                        final idx        = courses.indexOf(newValue!);
                        selectedCourseId = coursesIndex[idx];
                        lectures         = [];
                        lectureFromController.clear();
                        lectureToController.clear();
                      });
                      _getLectures(selectedCourseId!);
                    },
                  ),

                  const SizedBox(height: 30),

                  // -----------------------------------------------------------------
                  // Lectures list
                  // -----------------------------------------------------------------
                  if (lectures.isNotEmpty) ...[
                    Text('Lectures (${lectures.length}):',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                        color: Theme.of(context).colorScheme.onSurface,
                      )
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
                        itemBuilder: (ctx, i) {
                          return ListTile(
                            leading: Icon(Icons.book, color: blue2),
                            title: Text(lectures[i]['name']!,
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                              )
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // -----------------------------------------------------------------
                  // Lecture Range
                  // -----------------------------------------------------------------
                  const Text('Lecture Range',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    )
                  ),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: lectureFromController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'From',
                          labelStyle: const TextStyle(
                            fontFamily: 'League Spartan',
                            color: Color(0xFF165d96),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          labelStyle: const TextStyle(
                            fontFamily: 'League Spartan',
                            color: Color(0xFF165d96),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),

                  // -----------------------------------------------------------------
                  // Total Questions
                  // -----------------------------------------------------------------
                  const Text('Questions Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    )
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: questionsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Questions',
                      labelStyle: const TextStyle(
                        fontFamily: 'League Spartan',
                        color: Color(0xFF165d96),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // -----------------------------------------------------------------
                  // MCQ / T-F counts
                  // -----------------------------------------------------------------
                  const Text('Questions Type',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    )
                  ),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: mcqController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'MCQ',
                          labelStyle: const TextStyle(
                            fontFamily: 'League Spartan',
                            color: Color(0xFF165d96),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.bold,
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
                          labelStyle: const TextStyle(
                            fontFamily: 'League Spartan',
                            color: Color(0xFF165d96),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),

                  // -----------------------------------------------------------------
                  // Number of Copies (Doctor only)
                  // -----------------------------------------------------------------
                  if (isDoctor) ...[
                    const Text('Number of Copies',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                      )
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: copiesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Copies (≥1)',
                        labelStyle: const TextStyle(
                          fontFamily: 'League Spartan',
                          color: Color(0xFF165d96),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // -----------------------------------------------------------------
                  // Generate Button
                  // -----------------------------------------------------------------
                  Center(
                    child: ElevatedButton(
                      onPressed: validateQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue2,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        isDoctor ? 'Generate Paper Quiz' : 'Generate Quiz',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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