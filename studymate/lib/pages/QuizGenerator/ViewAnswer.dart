// ViewAnswer.dart

import 'package:flutter/material.dart';

class ViewAnswer extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;

  const ViewAnswer({
    Key? key,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  State<ViewAnswer> createState() => _ViewAnswerState();
}

class _ViewAnswerState extends State<ViewAnswer> {
  int currentQuestion = 0;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> questions = widget.questions;
    List<int> userAnswers = widget.userAnswers;

    // Get the current question data
    Map<String, dynamic> questionData = questions[currentQuestion];
    String questionText = questionData['question'];
    List<dynamic> options = questionData['options'];
    String correctAnswer = questionData['correctAnswer'];
    String explanation = questionData['explanation'];

    int correctOptionIndex;
    if (questionData['type'] == 'MCQ') {
      correctOptionIndex = correctAnswer.toUpperCase().codeUnitAt(0) - 65;
    } else {
      // For True/False questions
      correctOptionIndex = options.indexWhere(
          (option) => option.toLowerCase() == correctAnswer.toLowerCase());
    }

    int userSelectedIndex = userAnswers.length > currentQuestion
        ? userAnswers[currentQuestion]
        : -1;

    bool isCorrect = userSelectedIndex == correctOptionIndex;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165D96),
        title: const Text(
          'Review Answers',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            // Question navigation bar with colored buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    bool questionIsCorrect = false;
                    int correctOptionIdx;
                    if (questions[index]['type'] == 'MCQ') {
                      correctOptionIdx = questions[index]['correctAnswer']
                              .toUpperCase()
                              .codeUnitAt(0) -
                          65;
                    } else {
                      correctOptionIdx = questions[index]['options'].indexWhere(
                          (option) =>
                              option.toLowerCase() ==
                              questions[index]['correctAnswer'].toLowerCase());
                    }

                    int userAnswerIdx =
                        userAnswers.length > index ? userAnswers[index] : -1;

                    questionIsCorrect = userAnswerIdx == correctOptionIdx;

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
                                  ? const Color(0xFF165D96)
                                  : questionIsCorrect
                                      ? Colors.green
                                      : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                  fontFamily: 'League Spartan',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 50,
                            height: 2,
                            color: currentQuestion == index
                                ? const Color(0xFF165D96)
                                : questionIsCorrect
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display question text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                questionText,
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Display options
            ...List.generate(
              options.length,
              (index) {
                bool isUserSelected = userSelectedIndex == index;
                bool isCorrectOption = index == correctOptionIndex;

                Color textColor = Theme.of(context).colorScheme.onSurface;
                if (isUserSelected && !isCorrectOption) {
                  textColor = Colors.red;
                } else if (isCorrectOption) {
                  textColor = Colors.green;
                }

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align at the top
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isCorrectOption
                              ? Colors.green
                              : isUserSelected && !isCorrectOption
                                  ? Colors.red
                                  : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            questionData['type'] == 'MCQ'
                                ? String.fromCharCode(65 + index)
                                : options[index].toLowerCase() == 'true'
                                    ? 'T'
                                    : 'F',
                            style: const TextStyle(
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
                          options[index],
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Display explanation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explanation:',
                style: const TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165D96),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  explanation,
                  style: const TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: currentQuestion > 0
                        ? () {
                            setState(() {
                              currentQuestion--;
                            });
                          }
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion > 0
                            ? const Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: currentQuestion < questions.length - 1
                        ? () {
                            setState(() {
                              currentQuestion++;
                            });
                          }
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: currentQuestion < questions.length - 1
                            ? const Color(0xFF165D96)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
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
