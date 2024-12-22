import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Homebody extends StatefulWidget {
  const Homebody({super.key});

  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody> {
 
   Color _getCardColor(int index) {
    final List<Color> colors = [
      Color(0xFFF6F5FB), // Light Purple
      Color(0xFFFFF4F4), // Light Pink
      Color(0xFFF5F9F9), // White or another fallback color
    ];
    return colors[index % colors.length]; // Cycle through these colors
  }

  Color _getCardColorCourses(int index) {
    final List<Color> colors = [
      Color(0xFF165D96),
    ];
    return colors[index % colors.length]; // Cycle through these colors
  }

  String _getCourseBackground(int index) {
    final List<String> colors = [
      'lib/assets/img/bg1.jpg',
      'lib/assets/img/bg2.jpg',
      'lib/assets/img/bg3.jpg',
      'lib/assets/img/bg4.jpg',
      'lib/assets/img/bg5.jpg',
      'lib/assets/img/bg6.jpg',
      'lib/assets/img/bg7.jpg',
      'lib/assets/img/bg8.jpg',
    ];
    return colors[index % colors.length]; // Cycle through these colors
  }

  List<dynamic> _events = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchTodaysSchedule();
    recentCourses();
  }
   
  List<String> courses = [];
  List<String> coursesIndex = [];
  Future<void> recentCourses() async {
  
    const url = 'https://alyibrahim.pythonanywhere.com/recentCourses';  // Replace with your actual Flask server URL
    final username = Hive.box('userBox').get('username');
    print("USERNAME: $username");
      final Map<String, dynamic> requestBody = {
      'username': username,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
                print("print the jason a7a ? $jsonResponse");
                setState(() {
                                  courses = jsonResponse['courses'].cast<String>();
                                  coursesIndex = (jsonResponse['CourseID'] as List).map((item) => item['COId'].toString()).toList();

                });
                print(courses);
      }
      else {
        print('Request failed with status: ${response.body}.');

      }
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
          print('Failed to fetch today\'s schedule with status code ${response.statusCode}');
          
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
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Schedule',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      TextButton(
                        onPressed: () {
                          // navigate to the schedule page
                          // Navigator.pushNamed(context, '/SchedulePage');
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
                                color: Color(0xFF165D96),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF165D96),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _events.isEmpty
                          ? Center(
                              child: Text(
                                'No tasks for today.',
                                style: TextStyle(fontSize: 18, color: Color(0xFF165D96)),
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
                                        padding: const EdgeInsets.only(right: 14.0),
                                        child: Container(
                                          width: 150,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: _getCardColor(index),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _events[index]['Title'] ??
                                                      'No Title',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF165D96),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _formatTime(_events[index]['StartTime'] ?? 'Unknown Time'),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF165D96),
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
                              ],
                            ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Courses',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      TextButton(
                        onPressed: () {
                          // navigate to the schedule page
                          Navigator.pushNamed(context, '/Resources');
                        },
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF165D96),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF165D96),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      // Add a card for each course
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical, // Enable vertical scrolling
                        child: Column(
                          children: List.generate(
                            courses.length, // Limit to 2 courses (you can change this number)
                            (index) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14.0, // Spacing between cards
                              ),
                              child: Container(
                                width: 350, // Width of each card
                                height: 140, // Height of each card
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(15), // Rounded corners
                                  image: DecorationImage(
                                    image: AssetImage(_getCourseBackground(index)),
                                    fit: BoxFit
                                        .cover, // Make the image cover the entire card
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.black.withOpacity(
                                        0.5), // Add a semi-transparent overlay for readability
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        16.0), // Padding inside the card
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align to the left
                                      children: [
                                        Text(
                                          courses[index],
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ElevatedButton(
                                           onPressed: () {
                                                final String co = "COId";
                                                 Hive.box('userBox').put('COId', coursesIndex[index]);
                                                print("Course: ${courses[index]}, ${coursesIndex[index]}");
                                                 Navigator.pushNamed(context, '/CourseContent',arguments: {'courseId': courses[index], 'courseIndex': coursesIndex[index]},);
                                              
                                              },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.white, // Button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15), // Rounded corners
                                            ),
                                          ),
                                          child: Text(
                                            'Start',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Quizzes',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
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
                                color: Color(0xFF165D96),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF165D96),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      // Add a card for each course
                      SingleChildScrollView(
                        // padding: const EdgeInsets.only(left: 16.0),
                        scrollDirection: Axis.vertical, // Enable vertical scrolling
                        child: Column(
                          children: List.generate(
                            2, // Limit to 2 courses (you can change this number)
                            (index) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14.0, // Spacing between cards
                              ),
                              child: Container(
                                width: 350, // Width of each card
                                height:
                                    60, // Increased height to make space for the button
                                decoration: BoxDecoration(
                                  color: _getCardColorCourses(
                                      index), // Assign one of the colors
                                  borderRadius:
                                      BorderRadius.circular(15), // Rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      16.0), // Padding inside the card
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Align to the left
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.task_outlined,
                                              color: Colors.white),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Quiz ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(
                                      //     height:
                                      //         10), // Space between the text and button
                                      Row(
                                        children: [
                                          Text(
                                            '10 / 10',
                                            style: TextStyle(
                                              fontSize: 16,
                                              // color: Color(0xFF165D96),
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.arrow_circle_right_outlined,
                                            // color: Color(0xFF165D96),
                                            color: Colors.white,
                                            size: 30,
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
