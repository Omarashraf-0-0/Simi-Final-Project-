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

class _ViewAnswerState extends State<ViewAnswer>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeQuestion(int newIndex) {
    setState(() {
      currentQuestion = newIndex;
      _animationController.reset();
      _animationController.forward();
    });
  }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1c74bb),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1c74bb), Color(0xFF165d96)],
                ),
              ),
              child: const FlexibleSpaceBar(
                title: Text(
                  'Review Answers',
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 16),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Question Navigation Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    // Determine if the user's answer was correct
                    int userAnswer =
                        userAnswers.length > index ? userAnswers[index] : -1;
                    int correctIndex;

                    if (questions[index]['type'] == 'MCQ') {
                      correctIndex = questions[index]['correctAnswer']
                              .toUpperCase()
                              .codeUnitAt(0) -
                          65;
                    } else {
                      correctIndex = questions[index]['options'].indexWhere(
                          (option) =>
                              option.toLowerCase() ==
                              questions[index]['correctAnswer'].toLowerCase());
                    }

                    bool isCorrect = userAnswer == correctIndex;

                    return GestureDetector(
                      onTap: () => _changeQuestion(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: currentQuestion == index
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF165d96)
                                        ],
                                      )
                                    : null,
                                color: currentQuestion != index
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : null,
                                shape: BoxShape.circle,
                                boxShadow: currentQuestion == index
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF1c74bb)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'League Spartan',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (currentQuestion == index) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 20,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1c74bb),
                                      Color(0xFF165d96)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Question Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
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
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1c74bb),
                                        Color(0xFF165d96)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.help_outline,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        questionData['type'] == 'MCQ'
                                            ? 'Multiple Choice'
                                            : 'True/False',
                                        style: const TextStyle(
                                          fontFamily: 'League Spartan',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Question ${currentQuestion + 1}/${questions.length}',
                                    style: TextStyle(
                                      fontFamily: 'League Spartan',
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              questionText,
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Options
                      ...List.generate(
                        options.length,
                        (index) {
                          bool isUserSelected = userSelectedIndex == index;
                          bool isCorrectOption = index == correctOptionIndex;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCorrectOption
                                    ? Colors.green
                                    : (isUserSelected && !isCorrectOption)
                                        ? Colors.red
                                        : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCorrectOption
                                        ? Colors.green
                                        : (isUserSelected && !isCorrectOption)
                                            ? Colors.red
                                            : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isCorrectOption
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 20)
                                        : (isUserSelected && !isCorrectOption)
                                            ? const Icon(Icons.close,
                                                color: Colors.white, size: 20)
                                            : Text(
                                                questionData['type'] == 'MCQ'
                                                    ? String.fromCharCode(
                                                        65 + index)
                                                    : options[index]
                                                                .toLowerCase() ==
                                                            'true'
                                                        ? 'T'
                                                        : 'F',
                                                style: const TextStyle(
                                                  fontFamily: 'League Spartan',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      options[index],
                                      style: TextStyle(
                                        fontFamily: 'League Spartan',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isCorrectOption
                                            ? Colors.green
                                            : (isUserSelected &&
                                                    !isCorrectOption)
                                                ? Colors.red
                                                : const Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Explanation Card
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1c74bb).withOpacity(0.1),
                              const Color(0xFF165d96).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1c74bb).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1c74bb),
                                        Color(0xFF165d96)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.lightbulb_outline,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Explanation',
                                  style: TextStyle(
                                    fontFamily: 'League Spartan',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF165d96),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              explanation,
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 15,
                                color: Color(0xFF2C3E50),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Navigation Buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Button
                            Expanded(
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: currentQuestion > 0
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1c74bb),
                                            Color(0xFF165d96)
                                          ],
                                        )
                                      : null,
                                  color: currentQuestion > 0
                                      ? null
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: currentQuestion > 0
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1c74bb)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: currentQuestion > 0
                                        ? () =>
                                            _changeQuestion(currentQuestion - 1)
                                        : null,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: currentQuestion > 0
                                                ? Colors.white
                                                : Colors.grey.shade500,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Previous',
                                            style: TextStyle(
                                              fontFamily: 'League Spartan',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: currentQuestion > 0
                                                  ? Colors.white
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Next Button
                            Expanded(
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient:
                                      currentQuestion < questions.length - 1
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF1c74bb),
                                                Color(0xFF165d96)
                                              ],
                                            )
                                          : null,
                                  color: currentQuestion < questions.length - 1
                                      ? null
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow:
                                      currentQuestion < questions.length - 1
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF1c74bb)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: currentQuestion <
                                            questions.length - 1
                                        ? () =>
                                            _changeQuestion(currentQuestion + 1)
                                        : null,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Next',
                                            style: TextStyle(
                                              fontFamily: 'League Spartan',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: currentQuestion <
                                                      questions.length - 1
                                                  ? Colors.white
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: currentQuestion <
                                                    questions.length - 1
                                                ? Colors.white
                                                : Colors.grey.shade500,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
