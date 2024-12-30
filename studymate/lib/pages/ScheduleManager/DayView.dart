import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/Pop-ups/PopUps_Failed.dart';
import 'package:studymate/Pop-ups/PopUps_Success.dart';
import 'package:studymate/Pop-ups/PopUps_Warning.dart';
import 'dart:convert';

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasksForSelectedDay();
  }

  Future<void> _fetchTasksForSelectedDay() async {
    int userId = Hive.box('userBox').get('id');

    final startOfDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    String url = 'https://alyibrahim.pythonanywhere.com/schedule';
    Map<String, String> queryParams = {
      'user_id': userId.toString(),
      'start_date': startOfDay.toIso8601String().split('T')[0],
      'end_date': endOfDay.toIso8601String().split('T')[0],
    };

    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          print(_events);
          _isLoading = false;
        });
      } else {
        setState(() {
          _events = [];
          _isLoading = false;
        });
        print('Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      print("Error fetching schedule: $e");
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _isLoading = true;
    });
    _fetchTasksForSelectedDay();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _isLoading = true;
    });
    _fetchTasksForSelectedDay();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _isLoading = true;
      });
      _fetchTasksForSelectedDay();
    }
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Time Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatTime(event['StartTime']),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165D96),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(event['EndTime']),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1BC0C4),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Make only the Expanded widget (task card) slidable from end to start
          Expanded(
            child: Dismissible(
              key: ValueKey(event['Sid']),
              direction: DismissDirection.endToStart,
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                          "Are you sure you want to delete this task?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Delete"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                // Remove the item from data source
                setState(() {
                  _events.remove(event);
                });
                // Call API to delete task from server
                _deleteTask(event['Sid']);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                color: const Color(0xFF165D96),
                child: ListTile(
                  title: Text(
                    event['Title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    event['Description'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // Show a popup with all the data of the task
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Prepare the repeat information
                          String repeatInfo = event['Repeatance'] ?? 'None';
                          if (event['Repeatance'] != null &&
                              event['Repeatance'] != 'None' &&
                              event['RepeatEndDate'] != null) {
                            repeatInfo +=
                                ' until ${_formatDate(event['RepeatEndDate'])}';
                          }

                          // Prepare the reminder time
                          String reminderTime = event['ReminderBefore'] != null
                              ? '${event['ReminderBefore']} minutes before'
                              : 'None';

                          return AlertDialog(
                            title: Text(event['Title']),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  // Title (already in title)
                                  Text(
                                      'Description: ${event['Description'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text('Date: ${_formatDate(event['Date'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Start Time: ${_formatTime(event['StartTime'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'End Time: ${_formatTime(event['EndTime'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Location: ${event['Location'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Category: ${event['Category'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text('Repeat: $repeatInfo'),
                                  const SizedBox(height: 10),
                                  // Text('Reminder Time: $reminderTime'),
                                  // Add other task data here if available
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int taskId) async {
    String url = 'https://alyibrahim.pythonanywhere.com/delete_task';
    Map<String, String> jsonfile = {
      'Sid': taskId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(jsonfile),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Task deleted successfully
        showSuccessPopup(
          context,
          'Task Deleted',
          'Task has been deleted successfully.',
        );
      } else {
        // Handle error
        print('Failed to delete task: ${response.statusCode}');
        showFailedPopup(
          context,
          'Failed to Delete Task',
          'Failed to delete task. Please try again later.',
        );
      }
    } catch (e) {
      print('Error deleting task: $e');
      showFailedPopup(
        context,
        'Failed to Delete Task',
        'Failed to delete task. Please try again later.',
      );
    }
  }

  @override
  void dispose() {
    // If you have any subscriptions or controllers, dispose of them here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top Row: Date Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousDay,
                icon: const Icon(Icons.arrow_back_ios,
                    size: 25, color: Colors.black),
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE').format(_selectedDate), // Day name
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}",
                      style: const TextStyle(
                          fontSize: 24, color: Color(0xFF1BC0C4)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _nextDay,
                icon: const Icon(Icons.arrow_forward_ios,
                    size: 25, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Task List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks for this day.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return _buildEventCard(context, event);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
