import 'package:flutter/material.dart';
import '../services/enhanced_notification_service.dart';
import '../services/xp_tracker.dart';
import '../services/schedule_notification_sync.dart';

/// Mixin to easily add notification and XP functionality to any page
mixin NotificationHelpers<T extends StatefulWidget> on State<T> {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  final XPTracker _xpTracker = XPTracker();
  final ScheduleNotificationSync _scheduleSync = ScheduleNotificationSync();

  /// Award XP for completing a quiz
  Future<void> awardQuizXP(int score, int maxScore) async {
    int xp = XPTracker.xpQuizCompleted;
    
    // Bonus for perfect score
    if (score == maxScore) {
      xp = XPTracker.xpQuizPerfectScore;
    }
    
    await _xpTracker.addXP(xp, reason: 'Quiz Completed');
  }

  /// Award XP for completing an assignment
  Future<void> awardAssignmentXP() async {
    await _xpTracker.addXP(XPTracker.xpAssignmentCompleted, reason: 'Assignment Completed');
  }

  /// Award XP for completing a course
  Future<void> awardCourseCompletionXP() async {
    await _xpTracker.addXP(XPTracker.xpCourseCompleted, reason: 'Course Completed');
  }

  /// Award daily login XP
  Future<void> awardDailyLoginXP() async {
    await _xpTracker.addXP(XPTracker.xpDailyLogin, reason: 'Daily Login');
  }

  /// Award XP for reading course material
  Future<void> awardReadMaterialXP() async {
    await _xpTracker.addXP(XPTracker.xpReadMaterial, reason: 'Read Material');
  }

  /// Award XP for watching a video
  Future<void> awardWatchVideoXP() async {
    await _xpTracker.addXP(XPTracker.xpWatchVideo, reason: 'Watched Video');
  }

  /// Schedule a class notification
  Future<void> scheduleClass({
    required String className,
    required DateTime classTime,
    required String location,
  }) async {
    await _notificationService.scheduleClassNotification(
      className: className,
      classTime: classTime,
      location: location,
    );
  }

  /// Schedule quiz reminders
  Future<void> scheduleQuiz({
    required String quizName,
    required DateTime quizTime,
    String? quizId,
  }) async {
    await _notificationService.scheduleQuizReminders(
      quizName: quizName,
      quizTime: quizTime,
      quizId: quizId,
    );
  }

  /// Schedule assignment reminder
  Future<void> scheduleAssignment({
    required String assignmentName,
    required DateTime deadline,
    String? assignmentId,
  }) async {
    await _notificationService.scheduleAssignmentReminder(
      assignmentName: assignmentName,
      deadline: deadline,
      assignmentId: assignmentId,
    );
  }

  /// Setup daily study reminder
  Future<void> setupDailyReminder(TimeOfDay time, {String? message}) async {
    await _notificationService.scheduleDailyStudyReminder(
      time: time,
      customMessage: message,
    );
  }

  /// Sync all notifications from backend
  Future<void> syncAllNotifications() async {
    await _scheduleSync.syncAllNotifications();
  }

  /// Get current XP
  int getCurrentXP() => _xpTracker.getCurrentXP();

  /// Get current rank
  String getCurrentRank() => _xpTracker.getCurrentRank();

  /// Get study streak
  int getStudyStreak() => _xpTracker.getStudyStreak();
}

/// Standalone helper class for use outside widgets
class NotificationHelper {
  static final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  static final XPTracker _xpTracker = XPTracker();
  static final ScheduleNotificationSync _scheduleSync = ScheduleNotificationSync();

  /// Award XP for quiz completion
  static Future<void> awardQuizXP(int score, int maxScore) async {
    int xp = XPTracker.xpQuizCompleted;
    if (score == maxScore) {
      xp = XPTracker.xpQuizPerfectScore;
    }
    await _xpTracker.addXP(xp, reason: 'Quiz Completed');
  }

  /// Award XP for assignment completion
  static Future<void> awardAssignmentXP() async {
    await _xpTracker.addXP(XPTracker.xpAssignmentCompleted, reason: 'Assignment Completed');
  }

  /// Award XP for course completion
  static Future<void> awardCourseCompletionXP() async {
    await _xpTracker.addXP(XPTracker.xpCourseCompleted, reason: 'Course Completed');
  }

  /// Award daily login XP
  static Future<void> awardDailyLoginXP() async {
    await _xpTracker.addXP(XPTracker.xpDailyLogin, reason: 'Daily Login');
  }

  /// Award reading material XP
  static Future<void> awardReadMaterialXP() async {
    await _xpTracker.addXP(XPTracker.xpReadMaterial, reason: 'Read Material');
  }

  /// Award video watching XP
  static Future<void> awardWatchVideoXP() async {
    await _xpTracker.addXP(XPTracker.xpWatchVideo, reason: 'Watched Video');
  }

  /// Schedule class notification
  static Future<void> scheduleClass({
    required String className,
    required DateTime classTime,
    required String location,
  }) async {
    await _notificationService.scheduleClassNotification(
      className: className,
      classTime: classTime,
      location: location,
    );
  }

  /// Schedule quiz notification
  static Future<void> scheduleQuiz({
    required String quizName,
    required DateTime quizTime,
    String? quizId,
  }) async {
    await _notificationService.scheduleQuizReminders(
      quizName: quizName,
      quizTime: quizTime,
      quizId: quizId,
    );
  }

  /// Schedule assignment notification
  static Future<void> scheduleAssignment({
    required String assignmentName,
    required DateTime deadline,
    String? assignmentId,
  }) async {
    await _notificationService.scheduleAssignmentReminder(
      assignmentName: assignmentName,
      deadline: deadline,
      assignmentId: assignmentId,
    );
  }

  /// Setup daily study reminder
  static Future<void> setupDailyReminder(TimeOfDay time, {String? message}) async {
    await _notificationService.scheduleDailyStudyReminder(
      time: time,
      customMessage: message,
    );
  }

  /// Sync all notifications
  static Future<void> syncAllNotifications() async {
    await _scheduleSync.syncAllNotifications();
  }

  /// Show milestone notification
  static Future<void> showMilestone(String milestone, String description) async {
    await _notificationService.showMilestoneNotification(
      milestone: milestone,
      description: description,
    );
  }

  /// Get current XP
  static int getCurrentXP() => _xpTracker.getCurrentXP();

  /// Get current rank
  static String getCurrentRank() => _xpTracker.getCurrentRank();

  /// Get study streak
  static int getStudyStreak() => _xpTracker.getStudyStreak();
}
