import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:studymate/pages/Resources/Resources.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:studymate/theme/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Homebody extends StatefulWidget {
  const Homebody({super.key});

  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody> {
  String _getCourseBackground(int index) {
    final List<String> colors = [
      'assets/img/bg1.jpg',
      'assets/img/bg2.jpg',
      'assets/img/bg3.jpg',
      'assets/img/bg4.jpg',
      'assets/img/bg5.jpg',
      'assets/img/bg6.jpg',
      'assets/img/bg7.jpg',
      'assets/img/bg8.jpg',
    ];
    return colors[index % colors.length]; // Cycle through these colors
  }

  List<dynamic> _events = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchTodaysSchedule();
  }

  Future<void> _fetchTodaysSchedule() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    int UserID = Hive.box('userBox').get('id');
    try {
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=$UserID&start_date=${startOfDay.toIso8601String().split('T')[0]}&end_date=${endOfDay.toIso8601String().split('T')[0]}',
      ));
      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          _isLoading = false;
          print(_events);
        });
      } else {
        setState(() {
          _isLoading = false;
          _events = [];
          print(
              'Failed to fetch today\'s schedule with status code ${response.statusCode}');
        });
      }
    } catch (e) {
      print("Error fetching today's schedule: $e");
      setState(() {
        _isLoading = false;
        _events = [];
      });
    }
  }

  String _formatTime(String time) {
    try {
      // Parse the time string into a DateTime object
      final parsedTime = DateFormat('HH:mm:ss').parse(time);

      // Format the DateTime object into a 12-hour format
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      // Return a fallback value if parsing fails
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryBlue,
                                AppConstants.primaryCyan
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Today\'s Schedule',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryBlueDark,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScheduleView()));
                      },
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppConstants.primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _events.isEmpty
                        ? Center(
                            child: Text(
                              'No tasks for today.',
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF165D96)),
                            ),
                          )
                        : Column(
                            children: [
                              // Schedule Cards
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    _events.length,
                                    (index) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Container(
                                        width: 180,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppConstants.primaryBlue
                                                  .withOpacity(0.1),
                                              AppConstants.primaryCyan
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppConstants.primaryCyan
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppConstants.primaryBlue
                                                  .withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppConstants.primaryBlue,
                                                      AppConstants.primaryCyan
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.event_note_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _events[index]['Title'] ??
                                                        'No Title',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: AppConstants
                                                          .fontFamily,
                                                      color: AppConstants
                                                          .primaryBlueDark,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .access_time_rounded,
                                                        size: 14,
                                                        color: AppConstants
                                                            .primaryCyan,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        _formatTime(_events[
                                                                    index]
                                                                ['StartTime'] ??
                                                            'Unknown Time'),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppConstants
                                                              .primaryCyan,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryCyan,
                                AppConstants.primaryBlue
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Recent Courses',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryBlueDark,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // navigate to the schedule page
                        // Navigator.pushNamed(context, '/CoursesPage');
                      },
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppConstants.primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    // Add a card for each course
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // Enable vertical scrolling
                      child: Column(
                        children: List.generate(
                          1, // Limit to 2 courses (you can change this number)
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14.0, // Spacing between cards
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image:
                                      AssetImage(_getCourseBackground(index)),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryBlue
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppConstants.primaryBlueDark
                                          .withOpacity(0.7),
                                      AppConstants.primaryCyanDark
                                          .withOpacity(0.6),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Course ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  AppConstants.fontFamily,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'SRS',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontFamily:
                                                  AppConstants.fontFamily,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SRS()));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                AppConstants.primaryBlue,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Start Learning',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.fontFamily,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded,
                                                  size: 18),
                                            ],
                                          ),
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
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppConstants.primaryBlue,
                                AppConstants.primaryCyan
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Recent Quizzes',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryBlueDark,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // navigate to the schedule page
                        // Navigator.pushNamed(context, '/QuizzesPage');
                      },
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppConstants.primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    // Add a card for each course
                    SingleChildScrollView(
                      // padding: const EdgeInsets.only(left: 16.0),
                      scrollDirection:
                          Axis.vertical, // Enable vertical scrolling
                      child: Column(
                        children: List.generate(
                          2, // Limit to 2 courses (you can change this number)
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14.0, // Spacing between cards
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppConstants.primaryBlue,
                                    AppConstants.primaryCyan,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryBlue
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.quiz_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Quiz ${index + 1}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily:
                                                    AppConstants.fontFamily,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Completed',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily:
                                                    AppConstants.fontFamily,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFFFD700),
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '10/10',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppConstants.fontFamily,
                                                  color: AppConstants
                                                      .primaryBlueDark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
