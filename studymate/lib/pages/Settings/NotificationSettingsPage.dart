import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/enhanced_notification_service.dart';
import '../../Pop-ups/ModernPopup.dart';

/// Notification Settings Page
/// Allows users to customize notification preferences
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final EnhancedNotificationService _notificationService =
      EnhancedNotificationService();
  late Box settingsBox;

  // Notification toggles
  bool _scheduleNotifications = true;
  bool _quizReminders = true;
  bool _assignmentReminders = true;
  bool _rankNotifications = true;
  bool _dailyReminder = false;
  bool _streakNotifications = true;
  bool _milestoneNotifications = true;

  // Daily reminder time
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    settingsBox = await Hive.openBox('notificationSettings');

    setState(() {
      _scheduleNotifications =
          settingsBox.get('scheduleNotifications', defaultValue: true);
      _quizReminders = settingsBox.get('quizReminders', defaultValue: true);
      _assignmentReminders =
          settingsBox.get('assignmentReminders', defaultValue: true);
      _rankNotifications =
          settingsBox.get('rankNotifications', defaultValue: true);
      _dailyReminder = settingsBox.get('dailyReminder', defaultValue: false);
      _streakNotifications =
          settingsBox.get('streakNotifications', defaultValue: true);
      _milestoneNotifications =
          settingsBox.get('milestoneNotifications', defaultValue: true);

      final hour = settingsBox.get('dailyReminderHour', defaultValue: 20);
      final minute = settingsBox.get('dailyReminderMinute', defaultValue: 0);
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    await settingsBox.put(key, value);
  }

  Future<void> _selectDailyReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
      useRootNavigator: false,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });

      await settingsBox.put('dailyReminderHour', picked.hour);
      await settingsBox.put('dailyReminderMinute', picked.minute);

      // Update the scheduled notification if daily reminder is enabled
      if (_dailyReminder) {
        await _notificationService.cancelNotification(999999);
        await _notificationService.scheduleDailyStudyReminder(time: picked);

        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Daily reminder updated!'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('📚 Schedule & Classes'),
          _buildSettingTile(
            icon: Icons.schedule,
            title: 'Class Notifications',
            subtitle: 'Get notified 15 minutes before class',
            value: _scheduleNotifications,
            onChanged: (value) async {
              setState(() => _scheduleNotifications = value);
              await _saveSetting('scheduleNotifications', value);
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader('📝 Quizzes & Assignments'),
          _buildSettingTile(
            icon: Icons.quiz,
            title: 'Quiz Reminders',
            subtitle: '1 day and 1 hour before quizzes',
            value: _quizReminders,
            onChanged: (value) async {
              setState(() => _quizReminders = value);
              await _saveSetting('quizReminders', value);
            },
          ),
          _buildSettingTile(
            icon: Icons.assignment,
            title: 'Assignment Deadlines',
            subtitle: '2 days and 1 day before deadlines',
            value: _assignmentReminders,
            onChanged: (value) async {
              setState(() => _assignmentReminders = value);
              await _saveSetting('assignmentReminders', value);
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader('🎯 Achievements & Progress'),
          _buildSettingTile(
            icon: Icons.emoji_events,
            title: 'Rank Notifications',
            subtitle: 'Celebrate when you level up',
            value: _rankNotifications,
            onChanged: (value) async {
              setState(() => _rankNotifications = value);
              await _saveSetting('rankNotifications', value);
            },
          ),
          _buildSettingTile(
            icon: Icons.local_fire_department,
            title: 'Streak Notifications',
            subtitle: 'Celebrate study streaks',
            value: _streakNotifications,
            onChanged: (value) async {
              setState(() => _streakNotifications = value);
              await _saveSetting('streakNotifications', value);
            },
          ),
          _buildSettingTile(
            icon: Icons.stars,
            title: 'Milestone Notifications',
            subtitle: 'XP milestones and achievements',
            value: _milestoneNotifications,
            onChanged: (value) async {
              setState(() => _milestoneNotifications = value);
              await _saveSetting('milestoneNotifications', value);
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader('⏰ Daily Reminders'),
          _buildSettingTile(
            icon: Icons.notifications_active,
            title: 'Daily Study Reminder',
            subtitle: _dailyReminder
                ? 'Remind me at ${_dailyReminderTime.format(context)}'
                : 'Get a daily reminder to study',
            value: _dailyReminder,
            onChanged: (value) async {
              setState(() => _dailyReminder = value);
              await _saveSetting('dailyReminder', value);

              if (value) {
                await _notificationService.scheduleDailyStudyReminder(
                  time: _dailyReminderTime,
                );
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✅ Daily reminder set for ${_dailyReminderTime.format(context)}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                }
              } else {
                await _notificationService.cancelNotification(999999);
              }
            },
          ),

          if (_dailyReminder)
            ListTile(
              leading: const SizedBox(width: 40),
              title: const Text('Reminder Time'),
              subtitle: Text(_dailyReminderTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectDailyReminderTime,
            ),

          const SizedBox(height: 32),

          // Test notification button
          Center(
            child: ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Clear all notifications button
          Center(
            child: TextButton.icon(
              onPressed: _clearAllNotifications,
              icon: const Icon(Icons.clear_all, color: Colors.red),
              label: const Text(
                'Clear All Scheduled Notifications',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    // Use reflection to access private method (for testing only)
    final now = DateTime.now();
    await _notificationService.scheduleNotification(
      id: now.millisecondsSinceEpoch ~/ 1000,
      title: '🎉 Test Notification',
      body: 'If you see this, notifications are working perfectly!',
      scheduledDate: now.add(const Duration(seconds: 3)),
      channelId: 'general_notifications',
    );

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification will appear in 3 seconds...'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirm = await ModernPopup.showConfirmation(
      context: context,
      title: 'Clear All Notifications?',
      message:
          'This will cancel all scheduled notifications. You can re-sync them from your schedule.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirm == true) {
      await _notificationService.cancelAllNotifications();

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ All notifications cleared'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    }
  }
}
