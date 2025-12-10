import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/Pop-ups/PopUps_Failed.dart';
import 'package:studymate/Pop-ups/PopUps_Success.dart';
import 'dart:convert';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int _selectedDay = 0; // Tracks the selected day index
  DateTime _currentWeekStart = DateTime.now(); // Start of the current week
  Map<String, List<dynamic>> _tasksByDate = {}; // Tasks grouped by date
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    _fetchTasksForWeek(); // Fetch tasks when the widget is initialized
  }

  // Fetch tasks for the entire week from the backend
  Future<void> _fetchTasksForWeek() async {
    // Define the start and end of the current week
    DateTime weekStart = _currentWeekStart;
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    try {
      int userId = Hive.box('userBox').get('id');
      final uri = Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule',
      ).replace(queryParameters: {
        'user_id': userId.toString(),
        'start_date': weekStart.toIso8601String().split('T')[0],
        'end_date': weekEnd.toIso8601String().split('T')[0],
      });

      final response = await http.get(uri);

      if (!mounted) return; // Check if the widget is still mounted

      if (response.statusCode == 200) {
        List<dynamic> events = json.decode(response.body);

        // Group tasks by date
        Map<String, List<dynamic>> groupedTasks = {};
        for (var event in events) {
          String dateKey = event['Date'];
          if (!groupedTasks.containsKey(dateKey)) {
            groupedTasks[dateKey] = [];
          }
          groupedTasks[dateKey]!.add(event);
        }

        setState(() {
          _tasksByDate = groupedTasks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tasksByDate = {};
          _isLoading = false;
        });
        print("Failed to fetch tasks: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _tasksByDate = {};
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

  // Helper method to get the start of the week for a given date
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Helper method to format a date key for the tasks map
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Helper method to format a date
  String _formatDateShort(DateTime date, {String format = 'd MMM'}) {
    if (format == 'd MMM') {
      return "${date.day} ${_getMonthName(date.month)}";
    } else {
      return DateFormat(format).format(date);
    }
  }

  // Helper method to get the name of the month
  String _getMonthName(int month) {
    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  // Build task card
  Widget _buildTaskCard(BuildContext context, dynamic task, String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatTime(task['StartTime']),
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
                _formatTime(task['EndTime']),
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
              key: ValueKey(task['Sid']),
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
                  _tasksByDate[dateKey]!.remove(task);
                  if (_tasksByDate[dateKey]!.isEmpty) {
                    _tasksByDate.remove(dateKey);
                  }
                });
                // Call API to delete task from server
                _deleteTask(task['Sid']);
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
                    task['Title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    task['Description'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // Show a popup with all the data of the task
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Prepare the repeat information
                          String repeatInfo = task['Repeatance'] ?? 'None';
                          if (task['Repeatance'] != null &&
                              task['Repeatance'] != 'None' &&
                              task['RepeatEndDate'] != null) {
                            repeatInfo +=
                                ' until ${_formatDate(task['RepeatEndDate'])}';
                          }

                          return AlertDialog(
                            title: Text(task['Title']),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                      'Description: ${task['Description'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text('Date: ${_formatDate(task['Date'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Start Time: ${_formatTime(task['StartTime'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'End Time: ${_formatTime(task['EndTime'])}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Location: ${task['Location'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Category: ${task['Category'] ?? 'N/A'}'),
                                  const SizedBox(height: 10),
                                  Text('Repeat: $repeatInfo'),
                                  const SizedBox(height: 10),
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
                    icon: Icon(
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

  // Method to delete task from server
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

  // Methods for week navigation
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
      _isLoading = true;
    });
    _fetchTasksForWeek();
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      _isLoading = true;
    });
    _fetchTasksForWeek();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentWeekStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _currentWeekStart = _getStartOfWeek(pickedDate);
        _isLoading = true;
      });
      _fetchTasksForWeek();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the start and end of the current week
    DateTime weekStart = _currentWeekStart;
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    // Get the selected day's date
    DateTime selectedDate = weekStart.add(Duration(days: _selectedDay));
    String selectedDateKey = _formatDateKey(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Week Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousWeek,
                icon: Icon(Icons.arrow_back_ios,
                    size: 25, color: Theme.of(context).primaryColor),
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Row(
                  children: [
                    Text(
                      _formatDateShort(weekStart),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      " - ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDateShort(weekEnd),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1BC0C4),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _nextWeek,
                icon: Icon(Icons.arrow_forward_ios,
                    size: 25, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Day Selector (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                7,
                (index) {
                  DateTime day = weekStart.add(Duration(days: index));
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = index; // Update selected day
                      });
                    },
                    child: Container(
                      width: 75,
                      height: 35,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _selectedDay == index
                            ? const Color(0xFF165D96)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _formatDateShort(day, format: 'EEE'),
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          color: _selectedDay == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Task List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasksByDate[selectedDateKey]?.isEmpty ?? true
                    ? const Center(
                        child: Text(
                          "No tasks for this day.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasksByDate[selectedDateKey]?.length ?? 0,
                        itemBuilder: (context, index) {
                          var task = _tasksByDate[selectedDateKey]![index];
                          return _buildTaskCard(context, task, selectedDateKey);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
