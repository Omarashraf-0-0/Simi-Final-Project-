import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final List<Map<String, String>> notifications;

  NotificationPage({required this.notifications});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<Map<String, String>> notifications;
  bool isDeletingAll = false;

  @override
  void initState() {
    super.initState();
    notifications = List.from(widget.notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    const url =
        'https://alyibrahim.pythonanywhere.com/deleteNotification'; // Replace with your actual server URL

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
    }
  }

  Future<void> deleteAllNotifications() async {
    if (isDeletingAll) return; // Prevent multiple requests
    setState(() {
      isDeletingAll = true;
    });

    const url =
        'https://alyibrahim.pythonanywhere.com/deleteAllNotifications'; // Replace with your actual server URL

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

  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete All Notifications'),
          content:
              Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                deleteAllNotifications();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show confirmation dialog when deleting a single notification
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Delete Notification'),
              content:
                  Text('Are you sure you want to delete this notification?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // Return false
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true); // Return true
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed without selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Color(0xFF165D96),
      ),
      body: Column(
        children: [
          Expanded(
            child: notifications.isNotEmpty
                ? ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification['id']!),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (DismissDirection direction) async {
                          bool confirm =
                              await _showDeleteConfirmationDialog();
                          return confirm;
                        },
                        onDismissed: (direction) async {
                          final String notificationId =
                              notification['id']!;

                          // Remove the notification from the list
                          setState(() {
                            notifications.removeWhere((item) =>
                                item['id'] == notificationId);
                          });

                          // Call deleteNotification
                          await deleteNotification(notificationId);
                        },
                        child: NotificationTile(
                          id: notification['id']!,
                          title: notification['title']!,
                          body: notification['body']!,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text('No notifications'),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: notifications.isNotEmpty && !isDeletingAll
                  ? _showDeleteAllConfirmationDialog
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isDeletingAll
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete All Notifications'),
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

  const NotificationTile({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limiting the message to show only the first 100 characters (or your desired limit)
    String previewBody =
        body.length > 100 ? body.substring(0, 100) + '...' : body;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(previewBody), // Show the preview of the body
        leading: const Icon(Icons.notifications, color: Colors.blue),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Open a dialog on tap to show the full message
          _showDetailsDialog(context, title, body);
        },
      ),
    );
  }

  // Function to show the detailed dialog with the full message
  void _showDetailsDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            // Added SingleChildScrollView to handle long content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom header with blue color
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue,
                  width: double.infinity,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Body content (full message)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    body,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Close button at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext)
                          .pop(); // Use dialogContext to close the dialog
                    },
                    child: const Text('Close',
                        style: TextStyle(color: Colors.white)),
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