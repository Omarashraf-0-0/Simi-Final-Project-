import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    const url =
        'https://alyibrahim.pythonanywhere.com/deleteNotification';

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

    const url =
        'https://alyibrahim.pythonanywhere.com/deleteAllNotifications';

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
          const SnackBar(
            content: Text('All notifications deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete notifications'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
          title: const Text('Delete All Notifications'),
          content:
              const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                deleteAllNotifications();
              },
              child: const Text(
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
              title: const Text('Delete Notification'),
              content: const Text(
                  'Are you sure you want to delete this notification?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // Return false
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true); // Return true
                  },
                  child: const Text(
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
        backgroundColor: const Color(0xFF165D96),
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
                        key: UniqueKey(), // Use UniqueKey to ensure uniqueness
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (DismissDirection direction) async {
                          bool confirm =
                              await _showDeleteConfirmationDialog();
                          return confirm;
                        },
                        onDismissed: (direction) async {
                          final String notificationId =
                              notification['id']!;

                          // Remove the notification from the list using the index
                          setState(() {
                            notifications.removeAt(index);
                          });

                          // Call deleteNotification to remove it from the server
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
                : const Center(
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
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
    super.key,
    required this.id,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // Limit the message to show only the first 100 characters
    String previewBody =
        body.length > 100 ? '${body.substring(0, 100)}...' : body;

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
            // Handle long content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with blue background
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
                // Full message content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    body,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Close button
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
                          .pop(); // Close the dialog
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