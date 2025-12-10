// Quiz.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'QuizScore.dart';
import '../../Pop-ups/ConfirmationPopUp.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Quiz extends StatefulWidget {
  final int totalQuestions;
  final int mcqCount;
  final int tfCount;
  final Map<String, dynamic> quizData;
  final String coId;

  const Quiz({
    Key? key,
    required this.totalQuestions,
    required this.mcqCount,
    required this.tfCount,
    required this.quizData,
    required this.coId,
  }) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int currentQuestion = 0;
  int correctAnswers = 0;
  List<int> userAnswers = [];
  late int totalSecondsRemaining;
  Timer? timer;

  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    totalSecondsRemaining = 60 * widget.totalQuestions;

    questions = [];
    List<dynamic> quizQuestions = widget.quizData['questions'];

    for (var q in quizQuestions) {
      List<dynamic> options;

      String questionType = q["type"]
          .toString()
          .replaceAll(RegExp(r'[^a-zA-Z]'), '')
          .trim()
          .toUpperCase();

      if (questionType == "TF" || questionType == "TRUEFALSE") {
        options = ['True', 'False']; // Set options for TF questions

        // Assign options to the question object
        q["options"] = options;

        // Ensure correctAnswer is set to 'True' or 'False'
        String correctAnswer = q["answer"].toString().trim().toLowerCase();
        if (correctAnswer == 't' || correctAnswer == 'true') {
          q["answer"] = 'True';
        } else if (correctAnswer == 'f' || correctAnswer == 'false') {
          q["answer"] = 'False';
        } else {
          q["answer"] = 'True';
        }
      } else if (questionType == "MCQ") {
        // For MCQ questions, ensure options are available
        if (q.containsKey("options") && q["options"] != null) {
          options = q["options"];
        } else {
          options = [];
        }
      } else {
        // Unknown question type
        options = [];
        print("Unknown question type for question: ${q["question"]}");
      }

      // Ensure options are assigned
      q["options"] = options;

      Map<String, dynamic> question = {
        "question": q["question"],
        "options": q["options"], // Ensure options are included
        "correctAnswer": q["answer"],
        "selectedOption": -1,
        "type": questionType,
        "explanation": q["explanation"],
        "lecture": q["lecture"].toString(),
      };
      questions.add(question);
    }

    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSecondsRemaining > 0) {
        setState(() {
          totalSecondsRemaining--;
        });
      } else {
        submitQuiz();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void submitQuiz() async {
    // Stop the timer first
    stopTimer();

    // Calculate correct answers and prepare lists
    correctAnswers = 0;
    List<String> userAnsList = [];
    List<String> quizAnsList = [];
    List<String> lectureNumbers = [];
    
    // NEW: Prepare quiz analysis data for recommendation system
    List<Map<String, dynamic>> quizAnalysisData = [];

    for (int i = 0; i < questions.length; i++) {
      int selectedOptionIndex = questions[i]["selectedOption"];
      String correctAnswer = questions[i]["correctAnswer"];
      String lectureNum = questions[i]["lecture"]?.toString() ?? 'Unknown';
      String topic = questions[i]["topic"] ?? 'General Topic';  // Get topic from question

      lectureNumbers.add(lectureNum);
      quizAnsList.add(correctAnswer);

      bool isCorrect = false;

      if (selectedOptionIndex != -1) {
        String selectedAnswer = '';
        // Normalize question type
        String questionType = questions[i]["type"]
            .toString()
            .replaceAll(RegExp(r'[^a-zA-Z]'), '')
            .trim()
            .toUpperCase();

        if (questionType == "MCQ") {
          selectedAnswer = String.fromCharCode(65 + selectedOptionIndex);
        } else if (questionType == "TF" || questionType == "TRUEFALSE") {
          selectedAnswer = questions[i]["options"][selectedOptionIndex];
        }

        userAnsList.add(selectedAnswer);

        // Scoring Logic
        if (questionType == "MCQ") {
          if (selectedAnswer.toUpperCase() == correctAnswer.toUpperCase()) {
            correctAnswers++;
            isCorrect = true;
          }
        } else if (questionType == "TF" || questionType == "TRUEFALSE") {
          if (selectedAnswer.trim().toLowerCase() ==
              correctAnswer.trim().toLowerCase()) {
            correctAnswers++;
            isCorrect = true;
          }
        }
      } else {
        userAnsList.add('');
      }
      
      // Add to quiz analysis data for recommendation system
      quizAnalysisData.add({
        "Lecture": lectureNum,
        "Topic": topic,
        "Correct": isCorrect ? 1 : 0
      });
    }

    // Prepare submission data for original endpoint
    Map<String, dynamic> submissionData = {
      'UserID': await getUserID(),
      'UserAns': userAnsList.join(','),
      'QuizAns': quizAnsList.join(','),
      'LecNum': lectureNumbers.join(','),
      'co_id': widget.coId,
    };

    // Prepare data for quiz analysis endpoint (FOR AI RECOMMENDATION SYSTEM)
    Map<String, dynamic> analysisData = {
      'UserID': await getUserID(),
      'co_id': widget.coId,
      'quiz_results': quizAnalysisData
    };

    print('Submission Data: $submissionData');

    try {
      // Submit quiz results to both endpoints
      await submitToServer(submissionData);
      await submitQuizAnalysis(analysisData);  // Send to recommendation system

      // Calculate XP changes based on the quiz result
      int xpChange = 0;
      int totalQuestions = widget.totalQuestions;
      double scorePercentage = (correctAnswers / totalQuestions) * 100;
      bool isPassed =
          scorePercentage >= 50; // Assuming 50% is the passing score

      String message = ''; // Initialize message variable

      if (isPassed) {
        // User passed the quiz
        xpChange = correctAnswers; // 1 XP for each correct answer

        // Check for perfect score bonus
        if (scorePercentage == 100 && totalQuestions >= 10) {
          xpChange += 5; // Add 5 bonus XP
          message =
              'Congratulations! You earned $xpChange XP and a 5 XP bonus for a perfect score!';
        } else {
          message = 'Congratulations! You earned $xpChange XP.';
        }
      } else {
        // User failed the quiz
        xpChange = -5; // Deduct 5 XP
        message = 'You lost 5 XP for failing the quiz.';
      }

      // Update XP on the server
      await updateUserXP(xpChange);

      // Navigate to the QuizScore page and pass xpChange and message
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScore(
            score: correctAnswers,
            total: widget.totalQuestions,
            userAnswers: userAnswers,
            questions: questions,
            xpChange: xpChange,
            xpMessage: message,
          ),
        ),
      );
    } catch (e) {
      print('Error during quiz submission or XP update: $e');
      // You can show an error dialog to the user if necessary
    }
  }

  Future<int> getUserID() async {
    var userBox = await Hive.openBox('userBox');
    int userID =
        userBox.get('id', defaultValue: 0); // Make sure the key is correct
    print('Retrieved UserID: $userID');
    return userID;
  }

  Future<void> submitToServer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://alyibrahim.pythonanywhere.com/submit_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Quiz results submitted successfully.');
      } else {
        print('Failed to submit quiz results: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error submitting quiz results: $e');
    }
  }

  Future<void> submitQuizAnalysis(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/save_quiz_analysis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('✅ Quiz analysis submitted successfully to AI recommendation system.');
      } else {
        print('❌ Failed to submit quiz analysis: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error submitting quiz analysis: $e');
    }
  }

  Future<void> updateUserXP(int xpChange) async {
    const xpUrl = 'https://alyibrahim.pythonanywhere.com/set_xp';
    const titleUrl = 'https://alyibrahim.pythonanywhere.com/set_title';

    // Get the current XP from Hive
    var userBox = Hive.box('userBox');
    int currentXp = userBox.get('xp', defaultValue: 0);
    String username = userBox.get('username', defaultValue: '');

    int newXp = currentXp + xpChange;

    // Ensure XP doesn't go below zero
    if (newXp < 0) {
      newXp = 0;
    }

    // Update XP on the server
    final xpResponse = await http.post(
      Uri.parse(xpUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'xp': newXp}),
    );

    if (xpResponse.statusCode == 200) {
      // Update XP locally
      userBox.put('xp', newXp);
      print("XP updated successfully to $newXp");

      // Determine new title based on XP
      String newTitle;
      if (newXp >= 3000) {
        newTitle = 'El Batal';
      } else if (newXp >= 2200) {
        newTitle = 'Legend';
      } else if (newXp >= 1500) {
        newTitle = 'Mentor';
      } else if (newXp >= 1000) {
        newTitle = 'Expert';
      } else if (newXp >= 600) {
        newTitle = 'Challenger';
      } else if (newXp >= 300) {
        newTitle = 'Achiever';
      } else if (newXp >= 100) {
        newTitle = 'Explorer';
      } else {
        newTitle = 'NewComer';
      }

      // Check if the title has changed
      String currentTitle = userBox.get('title', defaultValue: '');
      if (currentTitle != newTitle) {
        // Update title on the server
        final titleResponse = await http.post(
          Uri.parse(titleUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'title': newTitle}),
        );

        if (titleResponse.statusCode == 200) {
          // Update title locally
          userBox.put('title', newTitle);
          print("Title updated successfully to $newTitle");
        } else {
          print("Failed to update title: ${titleResponse.reasonPhrase}");
        }
      }
    } else {
      print("Failed to update XP: ${xpResponse.reasonPhrase}");
    }
  }

  void selectOption(int index) {
    setState(() {
      questions[currentQuestion]["selectedOption"] = index;
      if (userAnswers.length > currentQuestion) {
        userAnswers[currentQuestion] = index;
      } else {
        userAnswers.add(index);
      }
    });
  }

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF165D96),
          title: Text('Quiz'),
        ),
        body: Center(
          child: Text('No questions available.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        title: Text(
          'Quiz',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.watch_later,
                  color: Color(0xFF165D96),
                  size: 24,
                ),
                SizedBox(width: 5),
                Text(
                  '${totalSecondsRemaining ~/ 60}:${(totalSecondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF165D96),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            // Question navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentQuestion = index;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: currentQuestion == index
                                  ? Color(0xFF165D96)
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontFamily: 'League Spartan',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 50,
                            height: 2,
                            color: currentQuestion == index
                                ? Color(0xFF165D96)
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Question text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                questions[currentQuestion]["question"],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'League Spartan',
                    ),
              ),
            ),
            // Options
            ...List.generate(
              questions[currentQuestion]["options"] != null
                  ? questions[currentQuestion]["options"].length
                  : 0,
              (index) {
                bool isSelected =
                    questions[currentQuestion]["selectedOption"] == index;

                // Process the option text to remove leading letters and dots
                String optionText =
                    questions[currentQuestion]["options"][index];
                // Remove leading 'A. ', 'B. ', 'C. ', or 'D. '
                optionText = optionText.replaceFirst(
                    RegExp(r'^[A-D]\.\s*', caseSensitive: false), '');

                return GestureDetector(
                  onTap: () => selectOption(index),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF165D96)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align at the top
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF165D96)
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              questions[currentQuestion]["type"] == "MCQ"
                                  ? String.fromCharCode(65 + index)
                                  : questions[currentQuestion]["options"][index]
                                      .substring(0, 1)
                                      .toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            optionText,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontFamily: 'League Spartan',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Color(0xFF165D96)
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            // Navigation buttons and Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Question Button
                  GestureDetector(
                    onTap: currentQuestion > 0 ? previousQuestion : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion > 0
                            ? Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Submit Button with Confirmation Dialog
                  ElevatedButton(
                    onPressed: () {
                      // Show confirmation popup
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationPopUp(
                          onConfirm: () {
                            Navigator.of(context).pop(); // Close the dialog
                            submitQuiz();
                          },
                          onCancel: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // Do nothing, return to quiz
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF165D96),
                      padding:
                          EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Next Question Button
                  GestureDetector(
                    onTap: currentQuestion < questions.length - 1
                        ? nextQuestion
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion < questions.length - 1
                            ? Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
