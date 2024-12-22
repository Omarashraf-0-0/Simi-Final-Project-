import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'QuizScore.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Quiz extends StatefulWidget {
  final int totalQuestions;
  final int mcqCount;
  final int tfCount;
  final Map<String, dynamic> quizData;
  final String coId; // Added coId

  const Quiz({
    Key? key,
    required this.totalQuestions,
    required this.mcqCount,
    required this.tfCount,
    required this.quizData,
    required this.coId, // Added coId
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

      if (q.containsKey("options") && q["options"] != null) {
        options = q["options"];
      } else {
        options = [];
      }

      String questionType = q["type"].toString().trim().toUpperCase();

      if (questionType == "TF") {
        options = ['True', 'False'];

        String correctAnswer = q["answer"].toString().trim().toLowerCase();
        if (correctAnswer == 't' || correctAnswer == 'true') {
          q["answer"] = 'True';
        } else if (correctAnswer == 'f' || correctAnswer == 'false') {
          q["answer"] = 'False';
        } else {
          q["answer"] = 'True';
        }
      }

      Map<String, dynamic> question = {
        "question": q["question"],
        "options": options,
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
    stopTimer();
    correctAnswers = 0;
    List<String> userAnsList = [];
    List<String> quizAnsList = [];
    List<String> lectureNumbers = [];

    for (int i = 0; i < questions.length; i++) {
      int selectedOptionIndex = questions[i]["selectedOption"];
      String correctAnswer = questions[i]["correctAnswer"];
      String lectureNum = questions[i]["lecture"] ?? 'Unknown';

      lectureNumbers.add(lectureNum);
      quizAnsList.add(correctAnswer);

      if (selectedOptionIndex != -1) {
        String selectedAnswer = '';
        if (questions[i]["type"] == "MCQ") {
          selectedAnswer = String.fromCharCode(65 + selectedOptionIndex);
        } else if (questions[i]["type"] == "TF") {
          selectedAnswer = questions[i]["options"][selectedOptionIndex];
        }

        userAnsList.add(selectedAnswer);

        if (questions[i]["type"] == "MCQ") {
          if (selectedAnswer.toUpperCase() == correctAnswer.toUpperCase()) {
            correctAnswers++;
          }
        } else if (questions[i]["type"] == "TF") {
          if (selectedAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
            correctAnswers++;
          }
        }
      } else {
        userAnsList.add('');
      }
    }

    Map<String, dynamic> submissionData = {
      'UserID': await getUserID(),
      'UserAns': userAnsList.join(','),
      'QuizAns': quizAnsList.join(','),
      'LecNum': lectureNumbers.join(','),
      'co_id': widget.coId, // Include co_id in submission
    };

    print('Submission Data: $submissionData');

    await submitToServer(submissionData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScore(
          score: correctAnswers,
          total: widget.totalQuestions,
          userAnswers: userAnswers,
          questions: questions,
        ),
      ),
    );
  }

  Future<int> getUserID() async {
    var userBox = await Hive.openBox('userBox');
    int userID = userBox.get('id', defaultValue: 0); // Make sure the key is correct
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
      backgroundColor: Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                questions[currentQuestion]["question"],
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(
              questions[currentQuestion]["options"].length,
              (index) {
                bool isSelected = questions[currentQuestion]["selectedOption"] == index;

                return GestureDetector(
                  onTap: () => selectOption(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF165D96) : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              questions[currentQuestion]["type"] == "MCQ"
                                  ? String.fromCharCode(65 + index)
                                  : questions[currentQuestion]["options"][index].toLowerCase() == 'true' ? 'T' : 'F',
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
                            questions[currentQuestion]["options"][index],
                            style: TextStyle(
                              fontFamily: 'League Spartan',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Color(0xFF165D96) : Colors.black,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: currentQuestion > 0 ? previousQuestion : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion > 0 ? Color(0xFF165D96) : Colors.grey.shade400,
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
                  ElevatedButton(
                    onPressed: submitQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF165D96),
                      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
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
                  GestureDetector(
                    onTap: currentQuestion < questions.length - 1 ? nextQuestion : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion < questions.length - 1 ? Color(0xFF165D96) : Colors.grey.shade400,
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