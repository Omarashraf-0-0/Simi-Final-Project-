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
import 'package:studymate/pages/Notifications/NotificationClass.dart';

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

  // Move TextEditingControllers and state variables here
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController StartTimeController = TextEditingController();
  final TextEditingController EndTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController reminderTimeController = TextEditingController();
  final TextEditingController repeatUntilController = TextEditingController();

  String _selectedCategory = "Study";
  String _selectedRepeat = "None";

  @override
  void initState() {
    super.initState();
    initializeNotificationPlugin();
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    StartTimeController.dispose();
    EndTimeController.dispose();
    locationController.dispose();
    reminderTimeController.dispose();
    repeatUntilController.dispose();
    super.dispose();
  }

  // Function to initialize the notification plugin
  void initializeNotificationPlugin() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
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
      if (!_showAddEventPopup) {
        // Reset the controllers and state variables when the popup is closed
        titleController.clear();
        descriptionController.clear();
        dateController.clear();
        StartTimeController.clear();
        EndTimeController.clear();
        locationController.clear();
        reminderTimeController.clear();
        repeatUntilController.clear();
        _selectedCategory = "Study";
        _selectedRepeat = "None";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1c74bb);
    const secondaryColor = Color(0xFF165d96);
    const accentColor = Color(0xFF18bebc);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.05),
                  Colors.white,
                  accentColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -60,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.08),
                          secondaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Column(
                  children: [
                    // Modern Gradient AppBar
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor,
                            secondaryColor,
                            accentColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Modern back button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Title with icon
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Schedule Manager",
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            "Manage your events",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Modern add button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  onPressed: _toggleAddEventPopup,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Modern Tabs with gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: List.generate(_labels.length, (index) {
                            final isSelected = _selectedIndex == index;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              primaryColor,
                                              secondaryColor,
                                            ],
                                          )
                                        : null,
                                    color:
                                        isSelected ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _labels[index],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Selected View
                    Expanded(
                      child: _views[_selectedIndex],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_showAddEventPopup) buildAddEventPopup(context),
      ],
    );
  }

  Widget buildAddEventPopup(BuildContext context) {
    const primaryColor = Color(0xFF1c74bb);
    const secondaryColor = Color(0xFF165d96);
    const accentColor = Color(0xFF18bebc);

    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleAddEventPopup, // Close the popup when tapping outside
        child: Container(
          color: Colors.black.withOpacity(0.6), // Dim background
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent event propagation to the background
              child: Material(
                borderRadius: BorderRadius.circular(25),
                elevation: 20,
                shadowColor: primaryColor.withOpacity(0.5),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Modern Gradient Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              secondaryColor,
                              accentColor,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.event_note_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add New Event",
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Fill in the details below",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Close button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: _toggleAddEventPopup,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // DEBUG: Test Data Loader
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("🐞 Debug: Load Test Case Data"),
                          items: [
                            "TC-02: Repeating Event (Buggy)",
                            "TC-03: Collision Event A",
                            "TC-03: Collision Event B",
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              final now = DateTime.now();
                              final todayStr =
                                  DateFormat('yyyy-MM-dd').format(now);
                              final nextWeekStr = DateFormat('yyyy-MM-dd')
                                  .format(now.add(const Duration(days: 7)));

                              if (value == "TC-02: Repeating Event (Buggy)") {
                                titleController.text = "Daily Standup (Test)";
                                dateController.text = todayStr;
                                StartTimeController.text = "09:00 AM";
                                EndTimeController.text = "09:30 AM";
                                locationController.text = "Zoom";
                                _selectedCategory = "Work";
                                _selectedRepeat = "Daily";
                                repeatUntilController.text = nextWeekStr;
                                reminderTimeController.text = "08:55 AM";
                                descriptionController.text =
                                    "Testing Bug #1: Repeating notifications failure.";
                              } else if (value == "TC-03: Collision Event A") {
                                titleController.text =
                                    "Math Study (Collision A)";
                                dateController.text = todayStr;
                                StartTimeController.text = "10:00 AM";
                                EndTimeController.text = "11:00 AM";
                                locationController.text = "Library";
                                _selectedCategory = "Study";
                                _selectedRepeat = "None";
                                reminderTimeController.text = "09:55 AM";
                                descriptionController.text =
                                    "Testing Bug #2: ID Collision (Event A).";
                              } else if (value == "TC-03: Collision Event B") {
                                titleController.text =
                                    "Physics Quiz (Collision B)";
                                dateController.text = todayStr;
                                StartTimeController.text = "10:00 AM";
                                EndTimeController.text = "11:00 AM";
                                locationController.text = "Classroom";
                                _selectedCategory = "Study";
                                _selectedRepeat = "None";
                                reminderTimeController.text = "09:55 AM";
                                descriptionController.text =
                                    "Testing Bug #2: ID Collision (Event B - Overwrites A).";
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Event Title Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Event Title",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Textfield(
                                    controller: titleController,
                                    hintText: "Enter event title",
                                    fillColor: Colors.grey[50],
                                    borderColor: const Color(0xFF1c74bb),
                                    borderRadius: 15.0,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Date Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Textfield(
                                    controller: dateController,
                                    hintText: "Select date",
                                    fillColor: Colors.grey[50],
                                    borderColor: const Color(0xFF1c74bb),
                                    borderRadius: 15.0,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    isDateField: true,
                                    isFutureDate: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Time Fields Row
                              Row(
                                children: [
                                  // Start Time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Start Time",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Textfield(
                                          controller: StartTimeController,
                                          hintText: "Start",
                                          fillColor: Colors.grey[50],
                                          borderColor: const Color(0xFF1c74bb),
                                          borderRadius: 15.0,
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                          isTimeField: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // End Time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "End Time",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Textfield(
                                          controller: EndTimeController,
                                          hintText: "End",
                                          fillColor: Colors.grey[50],
                                          borderColor: const Color(0xFF1c74bb),
                                          borderRadius: 15.0,
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                          isTimeField: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Category Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Category",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1c74bb), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    value: _selectedCategory,
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
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Location Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Textfield(
                                    controller: locationController,
                                    hintText: "Enter location",
                                    fillColor: Colors.grey[50],
                                    borderColor: const Color(0xFF1c74bb),
                                    borderRadius: 15.0,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Reminder Time Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Reminder Time",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Textfield(
                                    controller: reminderTimeController,
                                    hintText: "Select reminder time",
                                    fillColor: Colors.grey[50],
                                    borderColor: const Color(0xFF1c74bb),
                                    borderRadius: 15.0,
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    isTimeField: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Repeat Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Repeat",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1c74bb), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
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
                                ],
                              ),
                              if (_selectedRepeat != "None")
                                const SizedBox(height: 20),
                              // Repeat Until Field
                              if (_selectedRepeat != "None")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Repeat Until",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Textfield(
                                      controller: repeatUntilController,
                                      hintText: "Select end date",
                                      fillColor: Colors.grey[50],
                                      borderColor: const Color(0xFF1c74bb),
                                      borderRadius: 15.0,
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      isDateField: true,
                                      isFutureDate: true,
                                    ),
                                  ],
                                ),
                              if (_selectedRepeat != "None")
                                const SizedBox(height: 20),
                              // Description Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                      hintText: "Enter event description",
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF1c74bb), width: 2),
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    minLines: 4,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      // Modern Action Buttons
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextButton(
                                  onPressed: _toggleAddEventPopup,
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1c74bb),
                                      Color(0xFF165d96),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1c74bb)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
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
                                    } else if (StartTimeController
                                        .text.isEmpty) {
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
                                    } else if (locationController
                                        .text.isEmpty) {
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
                                      try {
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
                                        DateTime repeatUntil =
                                            _selectedRepeat != "None" &&
                                                    repeatUntilController
                                                        .text.isNotEmpty
                                                ? DateTime.parse(
                                                    repeatUntilController.text
                                                        .trim())
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
                                        } else if (reminderTime
                                            .isBefore(DateTime.now())) {
                                          showWarningPopup(
                                            context,
                                            "Error",
                                            "The reminder time cannot be in the past.",
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Save Event",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
      await NotificationService().scheduleNotification(
        title: title,
        body: description,
        scheduledDate: scheduledDate,
      );
      // await scheduleNotification(
      //   title: title,
      //   body: description,
      //   scheduledDate: scheduledDate,
      // );

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
          channelDescription:
              'Your channel description', // Optional description
          importance: Importance.max, // High visibility
          priority: Priority.high, // High priority
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
