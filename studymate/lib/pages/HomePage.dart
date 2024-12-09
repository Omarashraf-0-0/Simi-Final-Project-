// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/ProfilePage.dart';
import 'package:studymate/pages/ScheduleManager.dart';
import '../Classes/User.dart';
import 'package:studymate/pages/AboLayla/AboLayla.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class Homepage extends StatefulWidget {
  User? user;
  Homepage({
    super.key,
    this.user,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Future<void> Logout() async {
    Box userBox = Hive.box('userBox');
    await userBox.put('isLoggedIn', false);
    await userBox.put('loginTime', 0);
    // navigate to the login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  // Function to generate card colors
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
  }

  Future<void> _fetchTodaysSchedule() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    int UserID = Hive.box('userBox').get('id');
    try {
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=${UserID}&start_date=${startOfDay.toIso8601String().split('T')[0]}&end_date=${endOfDay.toIso8601String().split('T')[0]}',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // using hex color
        // title: Center(child: Text('Home Page')),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              size: 36,
              color: Colors.white,
            ),
            onPressed: () {
              // Code to open the drawer or any other action
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // Profile picture
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // navigate to the notifications page
                    // Navigator.pushNamed(context, '/NotificationsPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF165D96),
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                    minimumSize: Size(0, 0),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // navigate to the profile page
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profilepage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF165D96),
                    shape: CircleBorder(),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                    minimumSize: Size(0, 0),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('lib/assets/img/pfp.jpg'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF165D96),
              ),
              child: Row(
                children: [
                  // app logo
                  Image.asset(
                      'lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                      height: 60,
                      width: 60,
                      color: Colors.white),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Study Mate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the Home tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the Settings tap
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/img/ai_icon.png', width: 24),
              title: Text('Abo Layla'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboLayla()),
                );
                // Handle the Abo Lyla tap
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Handle the Help tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle the Logout tap
                Logout();
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Schedule'),
              onTap: () {
                // Handle the Close tap
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScheduleView()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
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
                      // Navigator.pushNamed(context, '/CoursesPage');
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
                        2, // Limit to 2 courses (you can change this number)
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
                                      'Course ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Intro to Artificial Intelligence',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add your start course functionality here
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
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // Adjust this value to make it float higher
        decoration: BoxDecoration(
          color: Color(0xFF165D96),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(69), // Round the top left corner
            topRight: Radius.circular(69), // Round the top right corner
            bottomLeft: Radius.circular(69), // Round the bottom left corner
            bottomRight: Radius.circular(69), // Round the bottom right corner
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10.0,
              offset: Offset(0, 4), // Shadow for floating effect
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Color(0xFF165D96),
            borderRadius: BorderRadius.circular(69),
          ),
          child: GNav(
            gap: 6,
            activeColor: Color(0xFF165D96),
            color: Colors.white,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            duration: Duration(milliseconds: 500),
            tabBackgroundColor: Colors.white,
            onTabChange: (index) {
              // Handle the tab change
              // print(index);
            },
            tabs: [
              GButton(icon: Ionicons.ios_home_outline, text: 'Home'),
              GButton(icon: Ionicons.ios_book_outline, text: 'Courses'),
              GButton(icon: Ionicons.hardware_chip_outline, text: 'Abo Lyla'),
              GButton(icon: Ionicons.trophy_outline, text: 'Leaderboard'),
            ],
          ),
        ),
      ),
    );
  }
}
// Card(
//                   elevation: 5,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Maths',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               '10:00 AM',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               color: Colors.blue,
//                             ),
//                             Text(
//                               'Room 101',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),