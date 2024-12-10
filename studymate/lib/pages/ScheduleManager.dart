import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting date (day name, day number)
import 'package:hive/hive.dart';
import 'HomePage.dart';
import 'package:http/http.dart' as http;

class ScheduleView extends StatefulWidget {
  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  int _selectedIndex = 0;

  final List<String> _labels = ["Day", "Week", "Month"];

  final List<Widget> _views = [
    DayView(),
    WeekView(),
    MonthView(),
  ];

  @override
  Widget build(BuildContext context) {
    print(Hive.box('userBox').get('id'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          onPressed: () {
            // Navigator.pushReplacement(
                // context, MaterialPageRoute(builder: (context) => Homepage()));
                Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined,
              color: Colors.white, size: 30),
        ),
        title: Center(
            child: Text("Schedule Manager",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                ))),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              // Add new event
              print("Add new event");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // Circular Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_labels.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _selectedIndex == index
                              ? Color(0xFF165D96)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                          // shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _labels[index], // First letter (D, W, M)
                            style: TextStyle(
                              fontSize: 24,
                              color: _selectedIndex == index
                                  ? Colors.white
                                  : Colors.black,
                              // fontWeight: _selectedIndex == index
                              //     ? FontWeight.bold
                              //     : FontWeight.normal,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 8),
                      // Text(
                      //   _labels[index],
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: _selectedIndex == index
                      //         ? Color(0xFF165D96)
                      //         : Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          // Selected View
          Expanded(
            child: _views[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
class DayView extends StatefulWidget {
  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateTime _selectedDate = DateTime.now(); // Initial date is today
  List<dynamic> _events = []; // List to store fetched events
  bool _isLoading = true; // Show loading spinner while fetching data

  // Fetch tasks for the selected day from the backend
  Future<void> _fetchTasksForSelectedDay() async {
    String formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    // Assuming user ID is stored in Hive
    int userId = Hive.box('userBox').get('id');
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
    // print('https://alyibrahim.pythonanywhere.com/schedule?user_id=$userId&start_date=${startOfDay.toIso8601String().split('T')[0]}&end_date=${endOfDay.toIso8601String().split('T')[0]}');
    // print(userId);
    // print(startOfDay);
    // print(endOfDay);

    try {
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userId&start_date=${startOfDay.toIso8601String().split('T')[0]}&end_date=${endOfDay.toIso8601String().split('T')[0]}',
      ));

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
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
      print("Error fetching schedule: $e");
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  // Format time from HH:mm:ss to hh:mm AM/PM
  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTasksForSelectedDay(); // Fetch tasks on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          // Top Row: Date Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(Duration(days: 1));
                    _isLoading = true;
                    _fetchTasksForSelectedDay(); // Fetch tasks for the new date
                  });
                },
                icon: Icon(Icons.arrow_back_ios, size: 25, color: Colors.black),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _isLoading = true;
                      _fetchTasksForSelectedDay(); // Fetch tasks for the selected date
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE').format(_selectedDate), // Day name
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}",
                      style: TextStyle(fontSize: 24, color: Color(0xFF1BC0C4)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(Duration(days: 1));
                    _isLoading = true;
                    _fetchTasksForSelectedDay(); // Fetch tasks for the new date
                  });
                },
                icon: Icon(Icons.arrow_forward_ios, size: 25, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Task List View
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? Center(
                        child: Text(
                          "No tasks for this day.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    Text(
                                      _formatTime(_events[index]['StartTime']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF165D96),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _formatTime(_events[index]['EndTime']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1BC0C4),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFF165D96),
                                    child: ListTile(
                                      title: Text(
                                        _events[index]['Title'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        _events[index]['Description'] ?? '',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
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

  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
class WeekView extends StatefulWidget {
  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int _selectedDay = 0; // Tracks the selected day index
  DateTime _currentWeekStart = DateTime.now(); // Start of the current week
  Map<String, List<dynamic>> _tasksByDate = {}; // Tasks grouped by date
  bool _isLoading = true;

  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

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
    DateTime weekEnd = weekStart.add(Duration(days: 6));

    try {
      int userId = Hive.box('userBox').get('id');
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userId&start_date=${weekStart.toIso8601String().split('T')[0]}&end_date=${weekEnd.toIso8601String().split('T')[0]}',
      ));

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
      setState(() {
        _tasksByDate = {};
        _isLoading = false;
      });
    }
  }

  // Helper method to get the start of the week for a given date
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the start and end of the current week
    DateTime weekStart = _currentWeekStart;
    DateTime weekEnd = weekStart.add(Duration(days: 6));

    // Get the selected day's date
    DateTime selectedDate = weekStart.add(Duration(days: _selectedDay));
    String selectedDateKey = _formatDateKey(selectedDate);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          // Week Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.subtract(Duration(days: 7));
                    _isLoading = true;
                    _fetchTasksForWeek();
                  });
                },
                icon: Icon(Icons.arrow_back_ios, size: 25, color: Colors.black),
              ),
              GestureDetector(
                onTap: () async {
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
                      _fetchTasksForWeek();
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      _formatDate(weekStart),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " - ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(weekEnd),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1BC0C4),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.add(Duration(days: 7));
                    _isLoading = true;
                    _fetchTasksForWeek();
                  });
                },
                icon: Icon(Icons.arrow_forward_ios,
                    size: 25, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),

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
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _selectedDay == index
                            ? Color(0xFF165D96)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _formatDate(day, format: 'EEE'),
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
          SizedBox(height: 20),

          // Task List View
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _tasksByDate[selectedDateKey]?.isEmpty ?? true
                    ? Center(
                        child: Text(
                          "No tasks for this day.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasksByDate[selectedDateKey]?.length ?? 0,
                        itemBuilder: (context, index) {
                          var task = _tasksByDate[selectedDateKey]![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatTime(task['StartTime']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF165D96),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _formatTime(task['EndTime']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF1BC0C4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                        color: Color(0xFF165D96),
                                        child: ListTile(
                                          title: Text(
                                            task['Title'],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            task['Description'] ?? '',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_circle_right_outlined,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ],
                                ),
                                // Card(
                                //   shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(15),
                                //   ),
                                //   elevation: 5,
                                //   color: Color(0xFF165D96),
                                //   child: ListTile(
                                //     title: Text(
                                //       task['Title'],
                                //       style: TextStyle(color: Colors.white),
                                //     ),
                                //     subtitle: Text(
                                //       "${task['StartTime']} - ${task['EndTime']}",
                                //       style: TextStyle(color: Colors.white70),
                                //     ),
                                //     trailing: Icon(
                                //       Icons.arrow_circle_right_outlined,
                                //       color: Colors.white,
                                //       size: 30,
                                //     ),
                                //   ),
                                // ),
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

  // Helper method to format a date key for the tasks map
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Helper method to format a date
  String _formatDate(DateTime date, {String format = 'd MMM'}) {
    if (format == 'd MMM') {
      return "${date.day} ${_getMonthName(date.month)}";
    } else {
      return DateFormat(format).format(date);
    }
  }

  // Helper method to get the name of the month
  String _getMonthName(int month) {
    const List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
class MonthView extends StatefulWidget {
  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime _currentDate = DateTime.now(); // Tracks the selected month and year
  final List<String> _months = [
    "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December"
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
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userId&start_date=${monthStart.toIso8601String().split('T')[0]}&end_date=${monthEnd.toIso8601String().split('T')[0]}',
      ));

      if (response.statusCode == 200) {
        List<dynamic> events = json.decode(response.body);
        //sort the tasks by date
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

        // sort the tasks by date
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Month-Year Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
                    _fetchTasksForMonth();
                  });
                },
                icon: Icon(Icons.arrow_back_ios, size: 25, color: Colors.black),
              ),
              GestureDetector(
                onTap: () => _showScrollableMonthYearPicker(context),
                child: Row(
                  children: [
                    Text(
                      "${_months[_currentDate.month - 1]}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " ${_currentDate.year}",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF1BC0C4),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
                    _fetchTasksForMonth();
                  });
                },
                icon: Icon(Icons.arrow_forward_ios, size: 25, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Task List View
          Expanded(
  child: _isLoading
      ? Center(child: CircularProgressIndicator())
      : _tasksByDate.isEmpty
          ? Center(
              child: Text(
                "No tasks for this month.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _tasksByDate.keys.length,
              itemBuilder: (context, index) {
                // Fetch the date key and associated tasks
                String dateKey = _tasksByDate.keys.elementAt(index);
                DateTime taskDate = DateTime.parse(dateKey);
                String dayName = DateFormat('EEEE').format(taskDate); // Day name
                String dayNumber = DateFormat('d').format(taskDate); // Day number

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the day name and number
                      Row(
                        children: [
                          Text(
                            dayName, // e.g., Monday
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            dayNumber, // e.g., 4
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF1BC0C4),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Display tasks for the specific date
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _tasksByDate[dateKey]?.length ?? 0,
                        itemBuilder: (context, taskIndex) {
                          var task = _tasksByDate[dateKey]![taskIndex];
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
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF165D96),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Vertical Divider
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    // End Time
                                    Text(
                                      _formatTime(task['EndTime']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1BC0C4),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFF165D96),
                                    child: ListTile(
                                      title: Text(
                                        task['Title'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        task['Description'] ?? '',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_circle_right_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
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

        return Container(
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
                        physics: FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                _months[index],
                                style: TextStyle(
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
                        physics: FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                (_startYear + index).toString(),
                                style: TextStyle(
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
                child: Text(
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
}
