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

class _QuizState extends State<Quiz> with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  int correctAnswers = 0;
  List<int> userAnswers = [];
  late int totalSecondsRemaining;
  Timer? timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late List<Map<String, dynamic>> questions;

  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    totalSecondsRemaining = 60 * widget.totalQuestions;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

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
    _animationController.dispose();
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
      String topic =
          questions[i]["topic"] ?? 'General Topic'; // Get topic from question

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
      await submitQuizAnalysis(analysisData); // Send to recommendation system

      // Calculate XP changes based on the quiz result
      int xpChange = 0;
      int totalQuestions = widget.totalQuestions;
      double scorePercentage = (correctAnswers / totalQuestions) * 100;
      bool isPassed = scorePercentage >= 50; // 50% is the passing score

      String message = '';

      if (isPassed) {
        // Passed: 10 XP base + 2 XP per correct answer
        xpChange = 10 + (correctAnswers * 2);
        message =
            'Passed! +$xpChange XP (10 base + ${correctAnswers * 2} for correct answers) 🎉';
      } else {
        // Failed: -5 XP penalty
        xpChange = -5;
        message = 'Failed! -5 XP. Keep practicing! 💪';
      }

      // Update XP on the server
      await updateUserXP(xpChange);

      // Navigate to the QuizScore page and pass xpChange and message
      Navigator.of(context, rootNavigator: false).push(
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
        print(
            '✅ Quiz analysis submitted successfully to AI recommendation system.');
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
      if (newXp >= 3500) {
        newTitle = 'El Batal';
      } else if (newXp >= 2500) {
        newTitle = 'Legend';
      } else if (newXp >= 1700) {
        newTitle = 'Mentor';
      } else if (newXp >= 1100) {
        newTitle = 'Expert';
      } else if (newXp >= 650) {
        newTitle = 'Challenger';
      } else if (newXp >= 350) {
        newTitle = 'Achiever';
      } else if (newXp >= 150) {
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
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, secondaryColor, accentColor],
                    ),
                  ),
                ),
              ),
            ),
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No questions available.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar with Timer
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
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Quiz Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Question ${currentQuestion + 1} of ${questions.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: totalSecondsRemaining < 60
                                    ? Colors.red
                                    : primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${totalSecondsRemaining ~/ 60}:${(totalSecondsRemaining % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: totalSecondsRemaining < 60
                                      ? Colors.red
                                      : primaryColor,
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
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Question Navigation Bar
                  Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        bool isAnswered =
                            questions[index]["selectedOption"] != -1;
                        bool isCurrent = currentQuestion == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentQuestion = index;
                              _animationController.reset();
                              _animationController.forward();
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: isCurrent
                                        ? LinearGradient(
                                            colors: [primaryColor, accentColor],
                                          )
                                        : null,
                                    color: isCurrent
                                        ? null
                                        : isAnswered
                                            ? accentColor.withOpacity(0.3)
                                            : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCurrent
                                          ? Colors.white
                                          : isAnswered
                                              ? accentColor
                                              : Colors.grey.shade400,
                                      width: isCurrent ? 3 : 2,
                                    ),
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color:
                                                  primaryColor.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : isAnswered
                                                ? accentColor
                                                : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isAnswered)
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        isCurrent ? primaryColor : accentColor,
                                    size: 14,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Question Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.2),
                                    accentColor.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                questions[currentQuestion]["type"] == "MCQ"
                                    ? 'Multiple Choice'
                                    : 'True/False',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.class_rounded,
                                    size: 16,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lec ${questions[currentQuestion]["lecture"]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          questions[currentQuestion]["question"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(
                    questions[currentQuestion]["options"] != null
                        ? questions[currentQuestion]["options"].length
                        : 0,
                    (index) {
                      bool isSelected =
                          questions[currentQuestion]["selectedOption"] == index;

                      String optionText =
                          questions[currentQuestion]["options"][index];
                      optionText = optionText.replaceFirst(
                          RegExp(r'^[A-D]\.\s*', caseSensitive: false), '');

                      return GestureDetector(
                        onTap: () {
                          selectOption(index);
                          _animationController.reset();
                          _animationController.forward();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.1),
                                      accentColor.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [primaryColor, accentColor],
                                        )
                                      : null,
                                  color:
                                      isSelected ? null : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    questions[currentQuestion]["type"] == "MCQ"
                                        ? String.fromCharCode(65 + index)
                                        : questions[currentQuestion]["options"]
                                                [index]
                                            .substring(0, 1)
                                            .toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: currentQuestion > 0
                        ? LinearGradient(
                            colors: [secondaryColor, primaryColor],
                          )
                        : null,
                    color: currentQuestion > 0 ? null : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: currentQuestion > 0
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: currentQuestion > 0 ? previousQuestion : null,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: currentQuestion > 0
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Submit Button
                Expanded(
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationPopUp(
                            onConfirm: () {
                              Navigator.of(context).pop();
                              submitQuiz();
                            },
                            onCancel: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Submit Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Next Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: currentQuestion < questions.length - 1
                        ? LinearGradient(
                            colors: [primaryColor, accentColor],
                          )
                        : null,
                    color: currentQuestion < questions.length - 1
                        ? null
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: currentQuestion < questions.length - 1
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: currentQuestion < questions.length - 1
                          ? nextQuestion
                          : null,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: currentQuestion < questions.length - 1
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
