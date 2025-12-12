// QuizScore.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:studymate/pages/XPChangePopup.dart';
import 'ViewAnswer.dart';

class QuizScore extends StatefulWidget {
  final int score;
  final int total;
  final List<int> userAnswers;
  final List<Map<String, dynamic>> questions;
  final int xpChange;
  final String xpMessage;

  const QuizScore({
    Key? key,
    required this.score,
    required this.total,
    required this.userAnswers,
    required this.questions,
    required this.xpChange,
    required this.xpMessage,
  }) : super(key: key);

  @override
  State<QuizScore> createState() => _QuizScoreState();
}

class _QuizScoreState extends State<QuizScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showXPChangePopup(context, widget.xpChange, widget.xpMessage);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showXPChangePopup(BuildContext context, int xpChange, String message) {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false, // Prevent closing the popup by tapping outside
      builder: (BuildContext context) {
        return XPChangePopup(
          xpChange: xpChange,
          message: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.total;
    bool isPass = percentage >= 0.5;
    Color resultColor = isPass ? Colors.green : Colors.red;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          slivers: [
            // Modern Gradient AppBar
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,
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
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isPass
                                    ? Icons.emoji_events_rounded
                                    : Icons.pending_actions_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Quiz Complete!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Score Card
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: resultColor.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Your Score',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow circle
                                  Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          resultColor.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Progress indicator
                                  CircularPercentIndicator(
                                    radius: 100.0,
                                    lineWidth: 16.0,
                                    animation: true,
                                    animationDuration: 1200,
                                    percent: percentage,
                                    center: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.score}',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: resultColor,
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 2,
                                          color: resultColor.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${widget.total}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: resultColor,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      resultColor.withOpacity(0.1),
                                      resultColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(percentage * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: resultColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Result Message Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              resultColor.withOpacity(0.1),
                              resultColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: resultColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isPass
                                  ? Icons.celebration_rounded
                                  : Icons.error_outline_rounded,
                              color: resultColor,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isPass ? 'Congratulations!' : 'Keep Trying!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPass
                                  ? 'You Nailed It! Keep Up\nThe Amazing Work 🎉'
                                  : 'Practice Makes Perfect\nYou\'ll Do Better Next Time 💪',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_rounded,
                              label: 'Correct',
                              value: '${widget.score}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.cancel_rounded,
                              label: 'Wrong',
                              value: '${widget.total - widget.score}',
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.quiz_rounded,
                              label: 'Total',
                              value: '${widget.total}',
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // View Answers Button
                      Container(
                        width: double.infinity,
                        height: 60,
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewAnswer(
                                  questions: widget.questions,
                                  userAnswers: widget.userAnswers,
                                ),
                              ),
                            );
                          },
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
                                Icons.visibility_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'View Answers',
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

                      const SizedBox(height: 16),

                      // Back to Home Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Back to Home',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
