import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'enhanced_notification_service.dart';

/// Service to sync schedule and automatically schedule notifications
class ScheduleNotificationSync {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();
  
  /// Sync all schedule items and create notifications
  Future<void> syncScheduleNotifications() async {
    try {
      final userBox = Hive.box('userBox');
      final username = userBox.get('username');
      
      if (username == null) {
        print('❌ No username found');
        return;
      }

      // Fetch schedule from backend
      final response = await http.get(
        Uri.parse('https://alyibrahim.pythonanywhere.com/get_schedule?username=$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> scheduleData = jsonDecode(response.body);
        await _scheduleNotificationsForSchedule(scheduleData);
        print('✅ Synced ${scheduleData.length} schedule items');
      } else {
        print('❌ Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing schedule: $e');
    }
  }

  /// Create notifications for all schedule items
  Future<void> _scheduleNotificationsForSchedule(List<dynamic> scheduleData) async {
    final now = DateTime.now();
    
    for (var item in scheduleData) {
      try {
        final String title = item['title'] ?? item['course_name'] ?? 'Class';
        final String? location = item['location'] ?? item['room'];
        final String? startTimeStr = item['start_time'] ?? item['time'];
        final String? dateStr = item['date'];
        
        if (startTimeStr == null) continue;

        // Parse date and time
        DateTime classDateTime;
        if (dateStr != null) {
          // If we have a specific date
          final dateParts = dateStr.split('-');
          final timeParts = startTimeStr.split(':');
          classDateTime = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        } else {
          // Use day of week for recurring classes
          final String? dayOfWeek = item['day_of_week'];
          if (dayOfWeek == null) continue;
          
          classDateTime = _getNextOccurrence(dayOfWeek, startTimeStr);
        }

        // Only schedule if in the future
        if (classDateTime.isAfter(now)) {
          await _notificationService.scheduleClassNotification(
            className: title,
            classTime: classDateTime,
            location: location ?? 'Campus',
          );
        }
      } catch (e) {
        print('Error scheduling notification for item: $e');
      }
    }
  }

  /// Get next occurrence of a day of week
  DateTime _getNextOccurrence(String dayOfWeek, String time) {
    final now = DateTime.now();
    final timeParts = time.split(':');
    final targetHour = int.parse(timeParts[0]);
    final targetMinute = int.parse(timeParts[1]);

    final dayMap = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    final targetDay = dayMap[dayOfWeek.toLowerCase()] ?? 1;
    var daysUntilTarget = (targetDay - now.weekday) % 7;
    
    if (daysUntilTarget == 0) {
      // Check if time has passed today
      final todayTarget = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
      if (todayTarget.isBefore(now)) {
        daysUntilTarget = 7; // Next week
      }
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      targetHour,
      targetMinute,
    );
  }

  /// Sync quiz notifications
  Future<void> syncQuizNotifications() async {
    try {
      final userBox = Hive.box('userBox');
      final username = userBox.get('username');
      
      if (username == null) return;

      final response = await http.get(
        Uri.parse('https://alyibrahim.pythonanywhere.com/get_upcoming_quizzes?username=$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> quizzes = jsonDecode(response.body);
        
        for (var quiz in quizzes) {
          final quizName = quiz['quiz_name'] ?? quiz['title'] ?? 'Quiz';
          final quizDateStr = quiz['quiz_date'] ?? quiz['date'];
          final quizTimeStr = quiz['quiz_time'] ?? quiz['time'];
          final quizId = quiz['quiz_id']?.toString();
          
          if (quizDateStr != null && quizTimeStr != null) {
            final quizDateTime = _parseDateTime(quizDateStr, quizTimeStr);
            
            if (quizDateTime.isAfter(DateTime.now())) {
              await _notificationService.scheduleQuizReminders(
                quizName: quizName,
                quizTime: quizDateTime,
                quizId: quizId,
              );
            }
          }
        }
        
        print('✅ Synced ${quizzes.length} quiz notifications');
      }
    } catch (e) {
      print('❌ Error syncing quiz notifications: $e');
    }
  }

  /// Sync assignment deadlines
  Future<void> syncAssignmentNotifications() async {
    try {
      final userBox = Hive.box('userBox');
      final username = userBox.get('username');
      
      if (username == null) return;

      final response = await http.get(
        Uri.parse('https://alyibrahim.pythonanywhere.com/get_assignments?username=$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> assignments = jsonDecode(response.body);
        
        for (var assignment in assignments) {
          final assignmentName = assignment['assignment_name'] ?? assignment['title'] ?? 'Assignment';
          final deadlineStr = assignment['deadline'] ?? assignment['due_date'];
          final assignmentId = assignment['assignment_id']?.toString();
          
          if (deadlineStr != null) {
            final deadline = DateTime.parse(deadlineStr);
            
            if (deadline.isAfter(DateTime.now())) {
              await _notificationService.scheduleAssignmentReminder(
                assignmentName: assignmentName,
                deadline: deadline,
                assignmentId: assignmentId,
              );
            }
          }
        }
        
        print('✅ Synced ${assignments.length} assignment notifications');
      }
    } catch (e) {
      print('❌ Error syncing assignment notifications: $e');
    }
  }

  /// Sync all notifications at once
  Future<void> syncAllNotifications() async {
    await Future.wait([
      syncScheduleNotifications(),
      syncQuizNotifications(),
      syncAssignmentNotifications(),
    ]);
  }

  /// Parse date and time strings
  DateTime _parseDateTime(String dateStr, String timeStr) {
    final dateParts = dateStr.split('-');
    final timeParts = timeStr.split(':');
    
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}
