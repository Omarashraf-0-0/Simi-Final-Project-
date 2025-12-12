import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Pop-ups/StylishPopup.dart';

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
                return await StylishPopup.question(
                  context: context,
                  title: 'Confirm Delete',
                  message: 'Are you sure you want to delete this task?',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
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
        await StylishPopup.success(
          context: context,
          title: 'Task Deleted',
          message: 'Task has been deleted successfully.',
        );
      } else {
        // Handle error
        print('Failed to delete task: ${response.statusCode}');
        await StylishPopup.error(
          context: context,
          title: 'Failed to Delete Task',
          message: 'Failed to delete task. Please try again later.',
        );
      }
    } catch (e) {
      print('Error deleting task: $e');
      await StylishPopup.error(
        context: context,
        title: 'Failed to Delete Task',
        message: 'Failed to delete task. Please try again later.',
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
          // Modern Week Navigation
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
                    onPressed: _previousWeek,
                    icon: const Icon(Icons.chevron_left_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Color(0xFF1c74bb), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateShort(weekStart),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        " - ",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        _formatDateShort(weekEnd),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
                    onPressed: _nextWeek,
                    icon: const Icon(Icons.chevron_right_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Modern Day Selector
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                DateTime day = weekStart.add(Duration(days: index));
                bool isSelected = _selectedDay == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1c74bb),
                                Color(0xFF165d96),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF1c74bb).withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 12 : 8,
                          offset: Offset(0, isSelected ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
