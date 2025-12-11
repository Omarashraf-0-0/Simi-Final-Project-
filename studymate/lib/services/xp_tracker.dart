import 'package:hive/hive.dart';
import 'enhanced_notification_service.dart';

/// Service to track XP changes and trigger rank notifications
class XPTracker {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  
  /// Update XP and check for rank changes
  Future<void> updateXP(int newXP, {String? reason}) async {
    final userBox = Hive.box('userBox');
    final oldXP = userBox.get('xp', defaultValue: 0);
    
    // Save new XP
    await userBox.put('xp', newXP);
    
    // Check for rank change
    await _notificationService.checkRankChange(newXP);
    
    // Check for XP milestones
    _checkXPMilestones(oldXP, newXP);
    
    // Track consecutive days
    _checkStudyStreak();
  }

  /// Add XP to current total
  Future<void> addXP(int xpToAdd, {String? reason}) async {
    final userBox = Hive.box('userBox');
    final currentXP = userBox.get('xp', defaultValue: 0);
    final newXP = currentXP + xpToAdd;
    
    await updateXP(newXP, reason: reason);
    
    print('✅ Added $xpToAdd XP${reason != null ? " for $reason" : ""}. Total: $newXP');
  }

  /// Check for XP milestones (500, 1000, 2000, etc.)
  void _checkXPMilestones(int oldXP, int newXP) {
    final milestones = [100, 250, 500, 750, 1000, 1500, 2000, 2500, 3000, 3500, 4000];
    
    for (var milestone in milestones) {
      if (oldXP < milestone && newXP >= milestone) {
        _notificationService.showMilestoneNotification(
          milestone: '$milestone XP Reached!',
          description: 'You\'ve earned $milestone experience points!',
        );
      }
    }
  }

  /// Check and update study streak
  void _checkStudyStreak() async {
    final userBox = Hive.box('userBox');
    final lastStudyDateStr = userBox.get('lastStudyDate');
    final currentStreak = userBox.get('studyStreak', defaultValue: 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastStudyDateStr == null) {
      // First time
      await userBox.put('lastStudyDate', today.toIso8601String());
      await userBox.put('studyStreak', 1);
      return;
    }
    
    final lastStudyDate = DateTime.parse(lastStudyDateStr);
    final lastStudyDay = DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
    final daysDifference = today.difference(lastStudyDay).inDays;
    
    if (daysDifference == 0) {
      // Same day, no change
      return;
    } else if (daysDifference == 1) {
      // Consecutive day - increment streak
      final newStreak = currentStreak + 1;
      await userBox.put('studyStreak', newStreak);
      await userBox.put('lastStudyDate', today.toIso8601String());
      
      // Show streak notification for milestones
      if (newStreak % 7 == 0 || newStreak == 3 || newStreak == 5 || newStreak >= 30) {
        await _notificationService.showStreakNotification(newStreak);
      }
    } else {
      // Streak broken
      await userBox.put('studyStreak', 1);
      await userBox.put('lastStudyDate', today.toIso8601String());
    }
  }

  /// Get current XP
  int getCurrentXP() {
    final userBox = Hive.box('userBox');
    return userBox.get('xp', defaultValue: 0);
  }

  /// Get current rank
  String getCurrentRank() {
    final xp = getCurrentXP();
    return _calculateRankFromXP(xp);
  }

  /// Get current study streak
  int getStudyStreak() {
    final userBox = Hive.box('userBox');
    return userBox.get('studyStreak', defaultValue: 0);
  }

  /// Calculate rank from XP
  String _calculateRankFromXP(int xp) {
    if (xp >= 3500) return 'El Batal';
    if (xp >= 2500) return 'Legend';
    if (xp >= 1700) return 'Mentor';
    if (xp >= 1100) return 'Expert';
    if (xp >= 650) return 'Challenger';
    if (xp >= 350) return 'Achiever';
    if (xp >= 150) return 'Explorer';
    return 'Beginner';
  }

  /// XP rewards for different actions
  static const int xpQuizCompleted = 50;
  static const int xpQuizPerfectScore = 100;
  static const int xpAssignmentCompleted = 75;
  static const int xpCourseCompleted = 200;
  static const int xpDailyLogin = 10;
  static const int xpStudyStreak7Days = 100;
  static const int xpStudyStreak30Days = 500;
  static const int xpReadMaterial = 15;
  static const int xpWatchVideo = 20;
}
