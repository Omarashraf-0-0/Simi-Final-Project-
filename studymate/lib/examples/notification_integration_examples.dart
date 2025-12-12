/*
 * EXAMPLE: How to integrate the notification system into your existing quiz page
 * 
 * This shows you how to award XP when a quiz is completed.
 * Copy the relevant parts into your actual quiz completion handler.
 */

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../helpers/notification_helpers.dart';
import '../services/enhanced_notification_service.dart';

class QuizCompletionExample extends StatefulWidget {
  const QuizCompletionExample({super.key});

  @override
  State<QuizCompletionExample> createState() => _QuizCompletionExampleState();
}

class _QuizCompletionExampleState extends State<QuizCompletionExample>
    with NotificationHelpers {
  // <-- Add this mixin to use notification helpers

  int _userScore = 0;
  final int _maxScore = 10;

  /// Call this when user completes a quiz
  Future<void> handleQuizCompletion(int score, int maxScore) async {
    // Award XP based on quiz performance
    await awardQuizXP(score, maxScore);

    // Perfect score: 100 XP + rank check + milestone check
    // Regular completion: 50 XP + rank check + milestone check

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              score == maxScore ? '🎉 Perfect Score!' : '✅ Quiz Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $score/$maxScore'),
              const SizedBox(height: 16),
              Text(
                score == maxScore
                    ? '+100 XP for perfect score!'
                    : '+50 XP for completion!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text('Current Rank: ${getCurrentRank()}'),
              Text('Total XP: ${getCurrentXP()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $_userScore/$_maxScore',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Simulate quiz completion
                setState(() {
                  _userScore = 10; // Perfect score
                });
                await handleQuizCompletion(_userScore, _maxScore);
              },
              child: const Text('Complete Quiz (Perfect Score)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Simulate quiz completion
                setState(() {
                  _userScore = 8; // Good score
                });
                await handleQuizCompletion(_userScore, _maxScore);
              },
              child: const Text('Complete Quiz (Good Score)'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
 * EXAMPLE: Schedule notifications when creating/viewing a quiz
 */
class QuizSchedulingExample extends StatelessWidget {
  const QuizSchedulingExample({super.key});

  Future<void> scheduleQuizFromData(Map<String, dynamic> quizData) async {
    // Example quiz data from your backend:
    // {
    //   "quiz_name": "Midterm Exam",
    //   "quiz_date": "2024-12-25",
    //   "quiz_time": "10:00",
    //   "quiz_id": "quiz_123"
    // }

    final quizName = quizData['quiz_name'] as String;
    final quizDateStr = quizData['quiz_date'] as String;
    final quizTimeStr = quizData['quiz_time'] as String;
    final quizId = quizData['quiz_id'] as String;

    // Parse date and time
    final dateParts = quizDateStr.split('-');
    final timeParts = quizTimeStr.split(':');

    final quizDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // Schedule notifications (1 day and 1 hour before)
    final notificationService = EnhancedNotificationService();
    await notificationService.scheduleQuizReminders(
      quizName: quizName,
      quizTime: quizDateTime,
      quizId: quizId,
    );

    // print('✅ Scheduled reminders for: $quizName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Scheduling Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Example: Schedule a quiz
            await scheduleQuizFromData({
              'quiz_name': 'Final Exam - Mathematics',
              'quiz_date': '2024-12-25',
              'quiz_time': '10:00',
              'quiz_id': 'quiz_math_final',
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Quiz reminders scheduled!')),
            );
          },
          child: const Text('Schedule Quiz Notifications'),
        ),
      ),
    );
  }
}

/*
 * EXAMPLE: Award XP when user reads course material
 */
class CourseMaterialExample extends StatefulWidget {
  const CourseMaterialExample({super.key});

  @override
  State<CourseMaterialExample> createState() => _CourseMaterialExampleState();
}

class _CourseMaterialExampleState extends State<CourseMaterialExample>
    with NotificationHelpers {
  final Set<String> _readMaterials = {};

  Future<void> markMaterialAsRead(String materialId) async {
    if (!_readMaterials.contains(materialId)) {
      _readMaterials.add(materialId);

      // Award XP for reading material
      await awardReadMaterialXP(); // +15 XP

      // Show feedback if widget is still mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ +15 XP for reading material!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> markVideoAsWatched(String videoId) async {
    // Award XP for watching video
    await awardWatchVideoXP(); // +20 XP

    // Show feedback if widget is still mounted
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ +20 XP for watching video!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Material Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Lecture Notes - Chapter 1'),
            trailing: ElevatedButton(
              onPressed: () => markMaterialAsRead('chapter_1'),
              child: const Text('Mark as Read'),
            ),
          ),
          ListTile(
            title: const Text('Video: Introduction to Flutter'),
            trailing: ElevatedButton(
              onPressed: () => markVideoAsWatched('video_1'),
              child: const Text('Mark as Watched'),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('XP: ${getCurrentXP()}'),
                  Text('Rank: ${getCurrentRank()}'),
                  Text('Streak: ${getStudyStreak()} days'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * EXAMPLE: Daily login XP
 * Add this to your app's main page or splash screen
 */
class DailyLoginExample {
  static Future<void> checkDailyLogin() async {
    // This should be called once per day when user opens the app

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check last login date from Hive
    final userBox = Hive.box('userBox');
    final lastLoginStr = userBox.get('lastLoginDate');

    if (lastLoginStr == null) {
      // First login
      await NotificationHelper.awardDailyLoginXP();
      await userBox.put('lastLoginDate', today.toIso8601String());
      return;
    }

    final lastLogin = DateTime.parse(lastLoginStr);
    final lastLoginDay =
        DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    if (today.isAfter(lastLoginDay)) {
      // New day - award XP
      // Daily login XP should be awarded using XPTracker in your actual implementation
      // For example: await XPTracker().addXP(XPTracker.xpDailyLogin, reason: 'Daily Login');
      await userBox.put('lastLoginDate', today.toIso8601String());
    }
  }
}
