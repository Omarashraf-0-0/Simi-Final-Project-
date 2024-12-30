// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/HomePage/Homebody.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/Performance/PerformanceHome.dart';
import 'package:studymate/pages/ProfilePage.dart';
import 'package:studymate/pages/Settings/Settings.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import '../../Classes/User.dart' as User;
import 'package:studymate/pages/AboLayla/AboLayla.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/Game/GameHome.dart';
import 'package:studymate/pages/Game/GameLeaderBoard.dart';
import 'package:studymate/pages/Leaderboard.dart';
import 'package:studymate/pages/OTP.dart';
import 'package:studymate/pages/Career/CareerHome.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:studymate/pages/Notifications/Notification.dart';
import '../Resuorces/Resources.dart';

class Homepage extends StatefulWidget {
  User.User? user = User.User();
  Homepage({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int idx = 0;

  void navBottom(int index) {
    setState(() {
      idx = index;
    });
  }

  final List<Widget> pages = [
    Homebody(),
    Resources(),
    AboLayla(),
    GameLeaderBoard(),
    CareerHome(),
  ];

  Future<void> Logout() async {
    Box userBox = Hive.box('userBox');
    await userBox.put('isLoggedIn', false);
    await userBox.put('loginTime', 0);
    // navigate to the login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  // Notifications list
  List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchTodaysSchedule();
    fetchNotifications(); // Fetch notifications on init
  }

  // Show Notifications Popup
  void _showNotificationsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: _notifications.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _notifications.length > 3
                        ? 3
                        : _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return ListTile(
                        title: Text(notification['title'] ?? ''),
                        subtitle: Text(notification['body'] ?? ''),
                        onTap: () {
                          // Handle notification tap if needed
                        },
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No notifications'),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate to the notifications page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(
                      notifications: _notifications,
                    ),
                  ),
                );
              },
              child: Text('View all notifications'),
            ),
          ],
        );
      },
    );
  }

  // Fetch today's schedule
  List<dynamic> _events = [];
  bool _isLoading = true;

  Future<void> _fetchTodaysSchedule() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    int UserID = Hive.box('userBox').get('id');
    print("User ID: $UserID");
    try {
      final response = await http.get(Uri.parse(
        'https://alyibrahim.pythonanywhere.com/schedule?user_id=$UserID&start_date=${startOfDay.toIso8601String().split('T')[0]}&end_date=${endOfDay.toIso8601String().split('T')[0]}',
      ));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _events = json.decode(response.body);
            _isLoading = false;
            print(_events);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _events = [];
            print(
                'Failed to fetch today\'s schedule with status code ${response.statusCode}');
          });
        }
      }
    } catch (e) {
      print("Error fetching today's schedule: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _events = [];
        });
      }
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
    // Define the branding colors
    final Color primaryColor = Color(0xFF1c74bb); // Blue 1
    final Color secondaryColor = Color(0xFF165d96); // Blue 2
    final Color accentColor = Color(0xFF18bebc); // Cyan 1
    final Color accentColor2 = Color(0xFF139896); // Cyan 2

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: Text(
          'Study Mate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // Profile picture and notifications
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              _showNotificationsPopup();
            },
          ),
          GestureDetector(
            onTap: () {
              // Navigate to the profile page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profilepage(
                          // user: widget.user,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey, // Placeholder color
                backgroundImage:
                    Hive.box('userBox').get('profileImageBase64') == null
                        ? null
                        : MemoryImage(base64Decode(
                            Hive.box('userBox').get('profileImageBase64'))),
                child: Hive.box('userBox').get('profileImageBase64') == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      )
                    : null, // Show icon only if no image is found
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, secondaryColor, accentColor),
      body: pages[idx],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer(BuildContext context, Color headerColor, Color accentColor) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: headerColor,
            ),
            child: Row(
              children: [
                // App logo
                Image.asset(
                  'lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                  height: 60,
                  width: 60,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'Study Mate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  text: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline,
                  text: 'Abo Layla',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboLayla()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.quiz_outlined,
                  text: 'Quiz Time',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.videogame_asset_outlined,
                  text: 'Gamification',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.leaderboard_outlined,
                  text: 'Leaderboard',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameLeaderBoard()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  text: 'CV Maker',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CareerHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.insights_outlined,
                  text: 'Insights',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InsightsPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.schedule_outlined,
                  text: 'Schedule',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScheduleView()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  text: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  text: 'Help',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OTP()),
                    );
                  },
                ),
                Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () {
                    Logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[700],
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF165d96),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), // Adjust padding
        child: GNav(
          gap: 8,
          activeColor: Color(0xFF165d96),
          color: Colors.white,
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabBackgroundColor: Colors.white,
          tabs: [
            GButton(icon: Ionicons.home_outline, text: 'Home'),
            GButton(icon: Ionicons.book_outline, text: 'Courses'),
            GButton(icon: Ionicons.chatbubble_ellipses_outline, text: 'Abo Layla'),
            GButton(icon: Ionicons.trophy_outline, text: 'Leaderboard'),
          ],
          selectedIndex: idx,
          onTabChange: (index) {
            setState(() {
              idx = index;
            });
            if (index == 0) {
              fetchNotifications();
              _fetchTodaysSchedule();
            }
          },
        ),
      ),
    );
  }

  Future<void> fetchNotifications() async {
    const url =
        'https://alyibrahim.pythonanywhere.com/getNotification'; // Replace with your actual Flask server URL
    final username = Hive.box('userBox').get('id');
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
      print("print the json: $jsonResponse");
      if (mounted) {
        setState(() {
          print("jsonResponse: $jsonResponse");
          var notifications = jsonResponse["notifications"]
              .map<Map<String, String>>((n) => {
                    "title": n["title"].toString(),
                    "body": n["body"].toString(),
                    "id": n["id"].toString()
                  })
              .toList();
          print("notifications: $notifications");
          _notifications = notifications;
        });
      }
    } else {
      print('Request failed with status: ${response.body}.');
    }
  }
}