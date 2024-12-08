import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting date (day name, day number)

import 'HomePage.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homepage()));
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
            onPressed: () {},
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

// Example Views
class DayView extends StatefulWidget {
  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  // Initial date is today
  DateTime _selectedDate = DateTime.now();

  // Example tasks based on the day
  final Map<String, List<String>> _tasksByDate = {
    '2024-12-02': ['Meeting with team', 'Prepare presentation'],
    '2024-12-03': ['Workout', 'Lunch with client'],
    '2024-12-04': ['Doctor appointment', 'Team check-in'],
    // Add more dates and tasks here
  };

  // Helper to get tasks for the selected day
  List<String> _getTasksForSelectedDay() {
    String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    return _tasksByDate[formattedDate] ?? ['No tasks for this day.'];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          // Top Row: Back Arrow, Date, Forward Arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate
                        .subtract(Duration(days: 1)); // Go to previous day
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
                      _selectedDate = pickedDate; // Update selected date
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      _selectedDate.weekday == 1
                          ? 'Monday'
                          : _selectedDate.weekday == 2
                              ? 'Tuesday'
                              : _selectedDate.weekday == 3
                                  ? 'Wednesday'
                                  : _selectedDate.weekday == 4
                                      ? 'Thursday'
                                      : _selectedDate.weekday == 5
                                          ? 'Friday'
                                          : _selectedDate.weekday == 6
                                              ? 'Saturday'
                                              : 'Sunday',
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
                    _selectedDate =
                        _selectedDate.add(Duration(days: 1)); // Go to next day
                  });
                },
                icon: Icon(Icons.arrow_forward_ios,
                    size: 25, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Task List View
          Expanded(
            child: ListView.builder(
              itemCount: _getTasksForSelectedDay().length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Text("12:00 PM"),
                            SizedBox(width: 8),
                            Text("|"),
                            SizedBox(width: 8),
                            Text(
                              "1:00 PM",
                              style: TextStyle(color: Color(0xFF1BC0C4)),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 300,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            color: Color(0xFF165D96),
                            child: ListTile(
                              title: Text(_getTasksForSelectedDay()[index],
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text("Details $index",
                                  style: TextStyle(color: Colors.white)),
                              trailing: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.arrow_circle_right_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
}

class WeekView extends StatefulWidget {
  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int _selectedDay = 0; // Tracks the selected day index
  DateTime _currentWeekStart = DateTime.now(); // Start of the current week

  // Example tasks tied to specific dates
  final Map<String, List<String>> _tasksByDate = {
    "2024-12-04": ['Meeting with team', 'Project review'],
    "2024-12-05": ['Workout', 'Lunch with client', 'Prepare presentation'],
    "2024-12-06": ['Doctor appointment', 'Team check-in'],
    "2024-12-07": ['Submit report', 'Client call', 'Dinner with family'],
    "2024-12-08": ['Yoga class', 'Weekly planning', 'Call supplier'],
    "2024-12-09": ['Grocery shopping', 'House cleaning'],
    "2024-12-10": ['Relax', 'Watch a movie'],
  };

  @override
  Widget build(BuildContext context) {
    // Calculate the start and end of the current week
    DateTime weekStart = _currentWeekStart
        .subtract(Duration(days: _currentWeekStart.weekday - 1));
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
                    _currentWeekStart = _currentWeekStart
                        .subtract(Duration(days: 7)); // Go to previous week
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
                      _currentWeekStart =
                          pickedDate; // Update week based on picked date
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
                        color: Color(
                            0xFF1BC0C4), // Apply the color to the end date
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentWeekStart = _currentWeekStart
                        .add(Duration(days: 7)); // Go to next week
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
            child: ListView.builder(
              itemCount: _tasksByDate[selectedDateKey]?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "12:00 PM",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1:00 PM",
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
                            title: Text(_tasksByDate[selectedDateKey]![index],
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text("Details of task $index",
                                style: TextStyle(color: Colors.white)),
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
    return format == 'd MMM'
        ? "${date.day} ${_getMonthName(date.month)}"
        : "${date.weekday == 1 ? 'Mon' : date.weekday == 2 ? 'Tue' : date.weekday == 3 ? 'Wed' : date.weekday == 4 ? 'Thu' : date.weekday == 5 ? 'Fri' : date.weekday == 6 ? 'Sat' : 'Sun'}";
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
}

class MonthView extends StatefulWidget {
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

  final Map<String, List<String>> _tasksByDate = {
    "2024-12-04": ['Meeting with team', 'Project review'],
    "2024-12-05": ['Workout', 'Lunch with client', 'Prepare presentation'],
    "2024-12-06": ['Doctor appointment', 'Team check-in'],
    "2024-12-07": ['Submit report', 'Client call', 'Dinner with family'],
    "2024-12-08": ['Yoga class', 'Weekly planning', 'Call supplier'],
    "2024-12-09": ['Grocery shopping', 'House cleaning'],
    "2024-12-10": ['Relax', 'Watch a movie'],
  };

  final int _startYear = 2000;
  final int _endYear = 2100;

  // Helper to format a date key for the tasks map
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
                    _currentDate =
                        DateTime(_currentDate.year, _currentDate.month - 1, 1);
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
                        color: Color(0xFF1BC0C4), // Year text color
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDate =
                        DateTime(_currentDate.year, _currentDate.month + 1, 1);
                  });
                },
                icon: Icon(Icons.arrow_forward_ios,
                    size: 25, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Display tasks for the selected month
          Expanded(
            child: ListView.builder(
              itemCount: _getTasksForSelectedMonth().length,
              itemBuilder: (context, index) {
                String dateKey =
                    _getTasksForSelectedMonth().keys.elementAt(index);
                DateTime taskDate = DateTime.parse(dateKey);
                String dayName =
                    DateFormat('EEEE').format(taskDate); // Get day name
                String dayNumber =
                    DateFormat('d').format(taskDate); // Get day number

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dayName, // Day name (e.g., Monday)
                            style: TextStyle(
                              fontSize: 28,
                              // color: Colors.black, // Color for day name
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            dayNumber, // Day number (e.g., 1)
                            style: TextStyle(
                              fontSize: 28,
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFF1BC0C4), // Day number color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // For each task, we will only create a card for the tasks on this date
                      ListView.builder(
                        shrinkWrap:
                            true, // This makes the inner listview shrink to fit the content
                        physics:
                            NeverScrollableScrollPhysics(), // Disable scrolling for inner list
                        itemCount: _tasksByDate[dateKey]?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "12:00 PM",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "1:00 PM",
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
                                    elevation: 5,
                                    color: Color(0xFF165D96),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      title:
                                          Text(_tasksByDate[dateKey]![index], style: TextStyle(color: Colors.white)),
                                      subtitle: Text("Details of task $index",
                                          style: TextStyle(color: Colors.white)),
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

  // Helper to get tasks for the selected month
  Map<String, List<String>> _getTasksForSelectedMonth() {
    Map<String, List<String>> tasksForSelectedMonth = {};
    _tasksByDate.forEach((dateKey, tasks) {
      DateTime date = DateTime.parse(dateKey);
      if (date.month == _currentDate.month && date.year == _currentDate.year) {
        tasksForSelectedMonth[dateKey] = tasks;
      }
    });
    return tasksForSelectedMonth;
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
                                  color: Color(0xFF1BC0C4), // Year text color
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
