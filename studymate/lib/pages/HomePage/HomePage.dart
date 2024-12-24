// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:studymate/pages/Career/CareerHome.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:studymate/pages/Notifications/Notification.dart';

// import '../../util/TextField.dart';

// import '../../Pop-ups/PopUps_Success.dart';
// import '../../Pop-ups/PopUps_Failed.dart';
// import '../../Pop-ups/PopUps_Warning.dart';
import '../Resuorces/Resources.dart';

// Import the NotificationsPage (you need to create this page)

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

  // Fetch notifications (you can replace this with your API call)

  void _showNotificationsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            // constraints: BoxConstraints(maxHeight: 400), // Adjust as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(height: 1),
                // Notifications list
                Flexible(
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
                Divider(height: 1),
                // View all notifications button
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
            ),
          ),
        );
      },
    );
  }

  // Your existing code...
  List<dynamic> _events = [];
  bool _isLoading = true;

  Future<void> _fetchTodaysSchedule() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    int UserID = Hive.box('userBox').get('id');
    print("mahdy was here $UserID");
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96), // using hex color
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
                    // Show the notifications popup
                    _showNotificationsPopup();
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profilepage(
                                  user: widget.user,
                                )));
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
                    backgroundColor: Colors.grey, // Placeholder color
                    backgroundImage:
                        Hive.box('userBox').get('profileImageBase64') == null
                            ? null
                            : MemoryImage(base64Decode(
                                Hive.box('userBox').get('profileImageBase64'))),
                    child: Hive.box('userBox').get('profileImageBase64') == null
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF01D7ED)), // Spinner color
                          )
                        : null, // Show spinner only if no image is found
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        // Your existing drawer code
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
                    color: Colors.white,
                  ),
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
              leading: Image.asset('lib/assets/img/ai_icon.png', width: 24),
              title: Text('Abo Layla'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboLayla()),
                );
                // Handle the Abo Layla tap
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/img/QuizTime.png', width: 24),
              title: Text('Quiz Time'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizHome()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.videogame_asset,
                  color: Colors.blue, size: 24), // Changed to game icon
              title: Text('Gamification'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameHome()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.leaderboard,
                  color: Colors.blue, size: 24), // Changed to leaderboard icon
              title: Text('Leaderboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameLeaderBoard()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description,
                  color: Colors.blue, size: 24), // Changed to CV icon
              title: Text('CV Maker'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CareerHome()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.insights_outlined),
              title: Text('Insights'),
              onTap: () {
                // Handle the Insights tap
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InsightsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Schedule'),
              onTap: () {
                // Handle the Schedule tap
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScheduleView()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
                // Handle the Settings tap
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
          ],
        ),
      ),
      body: pages[idx],
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
              setState(() {
                idx = index;
              });
              if (index == 0) {
                fetchNotifications();
                _fetchTodaysSchedule();
              }
            },
            tabs: [
              GButton(icon: Ionicons.ios_home_outline, text: 'Home'),
              GButton(icon: Ionicons.ios_book_outline, text: 'Courses'),
              GButton(icon: Ionicons.hardware_chip_outline, text: 'Abo Layla'),
              GButton(icon: Ionicons.trophy_outline, text: 'Leaderboard'),
            ],
          ),
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
