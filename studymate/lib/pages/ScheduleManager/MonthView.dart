import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:studymate/Pop-ups/PopUps_Failed.dart';
import 'package:studymate/Pop-ups/PopUps_Success.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime _currentDate = DateTime.now(); // Tracks the selected month and year
  final List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  final int _startYear = 2000;
  final int _endYear = 2100;

  Map<String, List<dynamic>> _tasksByDate = {}; // Fetched tasks grouped by date
  bool _isLoading = true; // Shows loading spinner while fetching tasks

  @override
  void initState() {
    super.initState();
    _fetchTasksForMonth(); // Fetch tasks for the current month on initialization
  }

  // Fetch tasks for the selected month
  Future<void> _fetchTasksForMonth() async {
    setState(() {
      _isLoading = true;
    });

    DateTime monthStart = DateTime(_currentDate.year, _currentDate.month, 1);
    DateTime monthEnd = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    try {
      int userId = Hive.box('userBox').get('id');

      final uri = Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule',
      ).replace(queryParameters: {
        'user_id': userId.toString(),
        'start_date': monthStart.toIso8601String().split('T')[0],
        'end_date': monthEnd.toIso8601String().split('T')[0],
      });

      final response = await http.get(uri);

      if (!mounted) return; // Check if the widget is still mounted

      if (response.statusCode == 200) {
        List<dynamic> events = json.decode(response.body);
        // Sort the tasks by date
        events.sort((a, b) => a['Date'].compareTo(b['Date']));

        // Group tasks by date
        Map<String, List<dynamic>> groupedTasks = {};
        for (var event in events) {
          String dateKey = event['Date'];
          if (!groupedTasks.containsKey(dateKey)) {
            groupedTasks[dateKey] = [];
          }
          groupedTasks[dateKey]!.add(event);
        }

        // Sort the tasks by start time within each date
        groupedTasks.forEach((key, value) {
          value.sort((a, b) => a['StartTime'].compareTo(b['StartTime']));
        });

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

  // Helper to show a scrollable month-year picker
  void _showScrollableMonthYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        int selectedMonth = _currentDate.month;
        int selectedYear = _currentDate.year;

        final monthScrollController =
            FixedExtentScrollController(initialItem: selectedMonth - 1);
        final yearScrollController =
            FixedExtentScrollController(initialItem: selectedYear - _startYear);

        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Scrollable Month Picker
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: monthScrollController,
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        perspective: 0.01,
                        onSelectedItemChanged: (index) {
                          selectedMonth = index + 1;
                        },
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                _months[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          childCount: 12,
                        ),
                      ),
                    ),

                    // Scrollable Year Picker
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: yearScrollController,
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        perspective: 0.01,
                        onSelectedItemChanged: (index) {
                          selectedYear = _startYear + index;
                        },
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                (_startYear + index).toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1BC0C4),
                                ),
                              ),
                            );
                          },
                          childCount: _endYear - _startYear + 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(selectedYear, selectedMonth, 1);
                    _fetchTasksForMonth();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
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

  // Build task card with Dismissible
  Widget _buildTaskCard(BuildContext context, dynamic task, String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Start Time
              Text(
                _formatTime(task['StartTime']),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165D96),
                ),
              ),
              const SizedBox(height: 5),
              // Vertical Divider
              Container(
                width: 2,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              // End Time
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
              key: ValueKey(task['Sid']), // Use unique identifier
              direction:
                  DismissDirection.endToStart, // Swipe from right to left
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1c74bb),
                      Color(0xFF165d96),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1c74bb).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      task['Title'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task['Description'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
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
                                      Text(
                                          'Date: ${_formatDate(task['Date'])}'),
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
                        icon: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Modern Month-Year Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c74bb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(
                            _currentDate.year, _currentDate.month - 1, 1);
                      });
                      _fetchTasksForMonth();
                    },
                    icon: const Icon(Icons.chevron_left_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showScrollableMonthYearPicker(context),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: Color(0xFF1c74bb), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _months[_currentDate.month - 1],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        " ${_currentDate.year}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18bebc),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c74bb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(
                            _currentDate.year, _currentDate.month + 1, 1);
                      });
                      _fetchTasksForMonth();
                    },
                    icon: const Icon(Icons.chevron_right_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Task List View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1c74bb),
                    ),
                  )
                : _tasksByDate.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1c74bb).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event_busy_rounded,
                                size: 64,
                                color: Color(0xFF1c74bb),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No events this month",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap + to add your first event",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasksByDate.keys.length,
                        itemBuilder: (context, index) {
                          // Fetch the date key and associated tasks
                          String dateKey = _tasksByDate.keys.elementAt(index);
                          DateTime taskDate = DateTime.parse(dateKey);
                          String dayName =
                              DateFormat('EEEE').format(taskDate); // Day name
                          String dayNumber =
                              DateFormat('d').format(taskDate); // Day number

                          List<dynamic> tasksForDate = _tasksByDate[dateKey]!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Modern Date Header
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1c74bb),
                                        Color(0xFF18bebc),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1c74bb)
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dayName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dayNumber,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${tasksForDate.length} ${tasksForDate.length == 1 ? 'event' : 'events'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Display tasks for the specific date
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _tasksByDate[dateKey]?.length ?? 0,
                                  itemBuilder: (context, taskIndex) {
                                    var task =
                                        _tasksByDate[dateKey]![taskIndex];
                                    return _buildTaskCard(
                                        context, task, dateKey);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
