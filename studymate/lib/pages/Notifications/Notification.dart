import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../Pop-ups/StylishPopup.dart';

class NotificationPage extends StatefulWidget {
  final List<Map<String, String>> notifications;

  const NotificationPage({super.key, required this.notifications});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<Map<String, String>> notifications;
  bool isDeletingAll = false;

  @override
  void initState() {
    super.initState();
    // Make a local copy of the notifications list
    notifications = List.from(widget.notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    const url = 'https://alyibrahim.pythonanywhere.com/deleteNotification';

    final Map<String, dynamic> requestBody = {
      'notificationId': notificationId,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print("Notification deleted successfully");
    } else {
      print('Request failed with status: ${response.body}.');
      // Optionally, show an error message if deletion fails
    }
  }

  Future<void> deleteAllNotifications() async {
    if (isDeletingAll) return; // Prevent multiple requests
    setState(() {
      isDeletingAll = true;
    });

    const url = 'https://alyibrahim.pythonanywhere.com/deleteAllNotifications';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All notifications deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete notifications'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred'),
        ),
      );
    } finally {
      setState(() {
        isDeletingAll = false;
      });
    }
  }

  void _showDeleteAllConfirmationDialog() async {
    final result = await StylishPopup.question(
      context: context,
      title: 'Delete All Notifications',
      message: 'Are you sure you want to delete all notifications?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
    if (result == true) {
      deleteAllNotifications();
    }
  }

  // Function to show confirmation dialog when deleting a single notification
  Future<bool> _showDeleteConfirmationDialog() async {
    return await StylishPopup.question(
          context: context,
          title: 'Delete Notification',
          message: 'Are you sure you want to delete this notification?',
          confirmText: 'Delete',
          cancelText: 'Cancel',
        ) ??
        false; // Return false if dialog is dismissed without selection
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1c74bb);
    final Color accentColor = Color(0xFF18bebc);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'All Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.home);
          },
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear All',
              onPressed: _showDeleteAllConfirmationDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header info card
          if (notifications.isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    accentColor.withOpacity(0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${notifications.length} ${notifications.length == 1 ? 'Notification' : 'Notifications'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Swipe left to delete',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Notifications list
          Expanded(
            child: notifications.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_rounded,
                                  color: Colors.white, size: 32),
                              SizedBox(height: 4),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (DismissDirection direction) async {
                          return await _showDeleteConfirmationDialog();
                        },
                        onDismissed: (direction) async {
                          final String notificationId = notification['id']!;
                          setState(() {
                            notifications.removeAt(index);
                          });
                          await deleteNotification(notificationId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Notification deleted'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: NotificationTile(
                          id: notification['id']!,
                          title: notification['title']!,
                          body: notification['body']!,
                          onDelete: () async {
                            bool confirm =
                                await _showDeleteConfirmationDialog();
                            if (confirm) {
                              setState(() {
                                notifications.removeAt(index);
                              });
                              await deleteNotification(notification['id']!);
                            }
                          },
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_rounded,
                            size: 80,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No Notifications',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You\'re all caught up!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1c74bb);
    final Color accentColor = Color(0xFF18bebc);

    // Limit the message to show only the first 100 characters
    String previewBody =
        body.length > 100 ? '${body.substring(0, 100)}...' : body;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            _showDetailsDialog(context, title, body, id, onDelete);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        previewBody,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show the detailed dialog with the full message
  void _showDetailsDialog(
    BuildContext context,
    String title,
    String body,
    String notificationId,
    VoidCallback onDelete,
  ) {
    final Color primaryColor = Color(0xFF1c74bb);
    final Color accentColor = Color(0xFF18bebc);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 16,
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Full message content
                Container(
                  padding: EdgeInsets.all(24),
                  constraints: BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                // Action buttons
                Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Delete notification
                            Navigator.of(dialogContext).pop();
                            onDelete();

                            // Show confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Marked as read'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Mark as Read',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }
}
