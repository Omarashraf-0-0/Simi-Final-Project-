import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:studymate/Pop-ups/PopUps_Failed.dart';
import 'package:studymate/Pop-ups/PopUps_Success.dart';
import 'package:studymate/Pop-ups/PopUps_Warning.dart';
import 'package:studymate/util/TextField.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'DayView.dart';
import 'WeekView.dart';
import 'MonthView.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  int _selectedIndex = 0;
  bool _showAddEventPopup = false;

  final List<String> _labels = ["Day", "Week", "Month"];
  final List<Widget> _views = [
    DayView(),
    WeekView(),
    MonthView(),
  ];

  // Initialize the notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotificationPlugin();
  }

  // Function to initialize the notification plugin
  void initializeNotificationPlugin() {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Initialize time zone data
    tz.initializeTimeZones();
  }

  void _toggleAddEventPopup() {
    setState(() {
      _showAddEventPopup = !_showAddEventPopup;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(Hive.box('userBox').get('id'));
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF165D96),
            leading: IconButton(
              onPressed: () {
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
                onPressed: _toggleAddEventPopup, // Toggle the popup
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
                            ),
                            child: Center(
                              child: Text(
                                _labels[index],
                                style: TextStyle(
                                  fontSize: 24,
                                  color: _selectedIndex == index
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily:
                                      GoogleFonts.leagueSpartan().fontFamily,
                                ),
                              ),
                            ),
                          ),
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
        ),
        if (_showAddEventPopup) buildAddEventPopup(context),
      ],
    );
  }

  Widget buildAddEventPopup(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController StartTimeController = TextEditingController();
    final TextEditingController EndTimeController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController reminderTimeController =
        TextEditingController();
    final TextEditingController repeatUntilController = TextEditingController();
    String _selectedCategory = "Study";
    String _selectedRepeat = "None";

    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleAddEventPopup, // Close the popup when tapping outside
        child: Container(
          color: Colors.black54, // Dim background
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent event propagation to the background
              child: Material(
                borderRadius:
                    BorderRadius.circular(15), // Ensure proper styling
                color: Colors.white, // Popup background color
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of the screen
                  height: MediaQuery.of(context).size.height *
                      0.9, // 90% of the screen height

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title Section with Background Color
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(
                              0xFF165D96), // New background color for the title
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Add New Event",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Event Title Row
                              Row(
                                children: [
                                  Text(
                                    "Title: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: titleController,
                                      hintText: "Event Title",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // Date Row
                              Row(
                                children: [
                                  Text(
                                    "Date: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: dateController,
                                      hintText: "Event Date",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      isDateField: true,
                                      isFutureDate: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Start time Row
                              Row(
                                children: [
                                  Text(
                                    "Start Time: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: StartTimeController,
                                      hintText: "Start Time",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      isTimeField: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // End time Row
                              Row(
                                children: [
                                  Text(
                                    "End Time: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: EndTimeController,
                                      hintText: "End Time",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      isTimeField: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // Category Row
                              Row(
                                children: [
                                  Text(
                                    "Category: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                      value:
                                          _selectedCategory, // Use the state variable here
                                      onChanged: (String? value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedCategory = value;
                                          });
                                        }
                                      },
                                      items: [
                                        "Study",
                                        "Work",
                                        "Personal",
                                        "Health",
                                        "Other",
                                      ].map((category) {
                                        return DropdownMenuItem<String>(
                                          value: category,
                                          child: Text(category),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),

                              // Location Field Row
                              Row(
                                children: [
                                  Text(
                                    "Location: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: locationController,
                                      hintText: "Enter Location",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // Reminder Time Row
                              Row(
                                children: [
                                  Text(
                                    "Reminder Time: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Textfield(
                                      controller: reminderTimeController,
                                      hintText: "Reminder Time",
                                      fillColor: Colors.grey[200],
                                      borderColor: Colors.blue,
                                      borderRadius: 10.0,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      isTimeField: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // Repeat Row
                              Row(
                                children: [
                                  Text(
                                    "Repeat: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      value: _selectedRepeat,
                                      onChanged: (String? value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedRepeat = value;
                                          });
                                        }
                                      },
                                      items: [
                                        "None",
                                        "Daily",
                                        "Weekly",
                                        "Monthly",
                                      ].map((repeat) {
                                        return DropdownMenuItem<String>(
                                          value: repeat,
                                          child: Text(repeat),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              // Repeat Until Row
                              if (_selectedRepeat != "None")
                                Row(
                                  children: [
                                    Text(
                                      "Repeat Until: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Textfield(
                                        controller: repeatUntilController,
                                        hintText: "Select Date",
                                        fillColor: Colors.grey[200],
                                        borderColor: Colors.blue,
                                        borderRadius: 10.0,
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        isDateField:
                                            true, // Custom handling for date picker
                                        isFutureDate:
                                            true, // Only allow future dates
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 15),
                              // Description Row
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  10), // Optional: For padding around
                                          child: TextFormField(
                                            controller: descriptionController,
                                            decoration: InputDecoration(
                                              hintText: "Description",
                                              fillColor: Colors.grey[200],
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            keyboardType: TextInputType
                                                .multiline, // Allow multiple lines
                                            maxLines:
                                                null, // Makes the field expand as needed
                                            minLines:
                                                5, // Initial height with 5 lines
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                      // Action Buttons
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _toggleAddEventPopup,
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Save the event details
                                if (titleController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a title for the event",
                                  );
                                } else if (dateController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a date for the event",
                                  );
                                } else if (StartTimeController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a start time for the event",
                                  );
                                } else if (EndTimeController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter an end time for the event",
                                  );
                                } else if (_selectedCategory.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please select a category for the event",
                                  );
                                } else if (locationController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a location for the event",
                                  );
                                } else if (reminderTimeController
                                    .text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a reminder time for the event",
                                  );
                                } else if (_selectedRepeat != "None" &&
                                    repeatUntilController.text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a repeat until date for the event",
                                  );
                                } else if (descriptionController
                                    .text.isEmpty) {
                                  showWarningPopup(
                                    context,
                                    "Error",
                                    "Please enter a description for the event",
                                  );
                                } else {
                                  // Parse the date and times into DateTime objects
                                  try {
                                    // Ensure the date format is correct (YYYY-MM-DD)
                                    final String eventDateText =
                                        dateController.text.trim();
                                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                        .hasMatch(eventDateText)) {
                                      throw FormatException(
                                          "Invalid date format. Expected YYYY-MM-DD.");
                                    }

                                    DateTime eventDate =
                                        DateTime.parse(eventDateText);

                                    // Parse and format StartTime
                                    final DateTime startTime =
                                        convertTo24HourFormatWithDate(
                                            dateController.text,
                                            StartTimeController.text);

                                    // Parse and format EndTime
                                    final DateTime endTime =
                                        convertTo24HourFormatWithDate(
                                            dateController.text,
                                            EndTimeController.text);

                                    // Parse and format ReminderTime
                                    DateTime reminderTime =
                                        convertTo24HourFormatWithDate(
                                            dateController.text,
                                            reminderTimeController.text);

                                    // Parse RepeatUntil directly as a date
                                    DateTime repeatUntil = _selectedRepeat !=
                                                "None" &&
                                            repeatUntilController
                                                .text.isNotEmpty
                                        ? DateTime.parse(
                                            repeatUntilController.text.trim())
                                        : eventDate;

                                    // Validation checks
                                    if (startTime.isAfter(endTime)) {
                                      showWarningPopup(
                                        context,
                                        "Error",
                                        "The start time cannot be after the end time.",
                                      );
                                    } else if (reminderTime
                                        .isAfter(startTime)) {
                                      showWarningPopup(
                                        context,
                                        "Error",
                                        "The reminder time cannot be after the start time.",
                                      );
                                    } else if (_selectedRepeat != "None" &&
                                        repeatUntil.isBefore(eventDate)) {
                                      showWarningPopup(
                                        context,
                                        "Error",
                                        "The repeat until date cannot be before the event date.",
                                      );
                                    } else {
                                      DateFormat outputFormat =
                                          DateFormat('yyyy-MM-dd HH:mm');
                                      // All validations passed. Save the event details to the database.
                                      // print("Event details are valid. Proceeding to save...");
                                      AddEvent(
                                        titleController.text,
                                        eventDateText,
                                        outputFormat.format(startTime),
                                        outputFormat.format(endTime),
                                        locationController.text,
                                        _selectedCategory,
                                        _selectedRepeat,
                                        descriptionController.text,
                                        outputFormat.format(reminderTime),
                                        outputFormat.format(repeatUntil),
                                      );
                                    }
                                  } catch (e) {
                                    // Handle parsing errors
                                    // print("Error: $e");
                                    showWarningPopup(
                                      context,
                                      "Error",
                                      "Invalid date or time format. Please check the values entered.",
                                    );
                                  }
                                }
                              },
                              child: Text("Save"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> AddEvent(
    String title,
    String date,
    String startTime,
    String endTime,
    String location,
    String category,
    String repeat,
    String description,
    String reminderTime,
    String repeatUntil,
  ) async {
    const url =
        'https://alyibrahim.pythonanywhere.com/AddSchedule'; // Replace with your actual Flask server URL
    int id = Hive.box('userBox').get('id');

    final Map<String, dynamic> data = {
      'id': '$id',
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'category': category,
      'repeat': repeat,
      'description': description,
      'reminderTime': reminderTime,
      'repeatUntil': repeatUntil,
    };
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data));

    if (response.statusCode == 200) {
      // Parse the reminderTime string into a DateTime object
      DateTime scheduledDate = DateTime.parse(reminderTime);

      // Schedule the notification
      await scheduleNotification(
        title: title,
        body: description,
        scheduledDate: scheduledDate,
      );

      // Show success popup
      showSuccessPopup(
        context,
        "Success",
        "Event added successfully",
      );

      // Close the add event popup
      _toggleAddEventPopup();
    } else {
      showFailedPopup(
        context,
        "Error",
        "Failed to add the event. ${response.statusCode} ${response.reasonPhrase}",
        "Retry",
      );
    }
  }

  // Function to schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Convert DateTime to TZDateTime for timezone compatibility
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.millisecondsSinceEpoch ~/ 1000, // Unique notification ID
      title, // Notification title
      body, // Notification body
      tzScheduledDate, // Time to show the notification
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '1', // Replace with your channel ID
          'Your Channel Name', // Replace with your channel name
          channelDescription: 'Your channel description', // Optional description
          importance: Importance.max, // High visibility
          priority: Priority.high, // High priority
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // print('Notification scheduled for: $tzScheduledDate');
  }
}

// Helper function to convert time to 24-hour format with date
DateTime convertTo24HourFormatWithDate(String dateTimeString, String time12h) {
  // Define the input formats for the date and time
  final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd');
  final DateFormat timeFormat12h = DateFormat('h:mm a');

  // Parse the date and time strings
  DateTime parsedDateTime = dateTimeFormat.parse(dateTimeString);
  DateTime parsedTime = timeFormat12h.parse(time12h);

  // Combine the date and time into a single DateTime object
  DateTime combinedDateTime = DateTime(
    parsedDateTime.year,
    parsedDateTime.month,
    parsedDateTime.day,
    parsedTime.hour,
    parsedTime.minute,
  );

  return combinedDateTime;
}