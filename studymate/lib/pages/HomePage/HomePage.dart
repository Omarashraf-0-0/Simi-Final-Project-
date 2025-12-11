// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/HomePage/Homebody.dart';
import 'package:studymate/pages/ProfilePage.dart';
import 'package:studymate/pages/Settings/Settings.dart';
import 'package:studymate/pages/AboLayla/AboLayla.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:studymate/pages/QuizGenerator/QuizHome.dart';
import 'package:studymate/pages/Game/GameHome.dart';
import 'package:studymate/pages/Game/GameLeaderBoard.dart';
import 'package:studymate/pages/Career/CareerHome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:studymate/pages/Notifications/Notification.dart';
import '../Resuorces/Resources.dart';
import '../../Classes/User.dart' as Student;
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../main.dart' show themeManager;

class Homepage extends StatefulWidget {
  final Student.Student? student;

  const Homepage({
    super.key,
    this.student,
  });

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
    await userBox.clear(); // Clear all user data
    // navigate to the login page
    if (mounted) {
      context.go(AppRoutes.login);
    }
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
    final Color primaryColor = Color(0xFF1c74bb);
    final Color accentColor = Color(0xFF18bebc);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
          child: Container(
            constraints: BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_notifications.isNotEmpty)
                              Text(
                                '${_notifications.length} ${_notifications.length == 1 ? 'notification' : 'notifications'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: _notifications.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _notifications.length > 3
                              ? 3
                              : _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, accentColor],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.notifications_active_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  notification['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  notification['body'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                                onTap: () {
                                  // Handle notification tap
                                },
                              ),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_off_rounded,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // Footer
                if (_notifications.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                notifications: _notifications,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View All Notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fetch today's schedule
  List<dynamic> _events = [];

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
            print(_events);
          });
        }
      } else {
        if (mounted) {
          setState(() {
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
          _events = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the branding colors
    final Color primaryColor = Color(0xFF1c74bb); // Blue 1
    final Color secondaryColor = Color(0xFF165d96); // Blue 2
    final Color accentColor = Color(0xFF18bebc); // Cyan 1

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor,
                accentColor,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Builder(builder: (context) {
              return Padding(
                padding: EdgeInsets.only(left: 8),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                    height: 26,
                    width: 26,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Study Mate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Notifications with badge
              Container(
                margin: EdgeInsets.only(right: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          _showNotificationsPopup();
                        },
                      ),
                    ),
                    if (_notifications.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red[400]!,
                                Colors.red[600]!,
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              _notifications.length > 9
                                  ? '9+'
                                  : _notifications.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Profile avatar
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profilepage()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: Hive.box('userBox')
                                  .get('profileImageBase64') ==
                              null
                          ? null
                          : MemoryImage(base64Decode(
                              Hive.box('userBox').get('profileImageBase64'))),
                      child:
                          Hive.box('userBox').get('profileImageBase64') == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context, primaryColor, secondaryColor, accentColor),
      body: pages[idx],
      extendBody: true,
      bottomNavigationBar:
          _buildBottomNavigationBar(primaryColor, secondaryColor, accentColor),
    );
  }

  Widget _buildDrawer(BuildContext context, Color primaryColor,
      Color secondaryColor, Color accentColor) {
    final username = Hive.box('userBox').get('username') ?? 'User';
    final email = Hive.box('userBox').get('email') ?? 'user@example.com';
    final level = Hive.box('userBox').get('level') ?? 1;
    final title = Hive.box('userBox').get('title') ?? 'Newcomer';

    return Drawer(
      child: Column(
        children: [
          // User Profile Header with Gradient
          Container(
            width: double.infinity,
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
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        backgroundImage: Hive.box('userBox')
                                    .get('profileImageBase64') ==
                                null
                            ? null
                            : MemoryImage(base64Decode(
                                Hive.box('userBox').get('profileImageBase64'))),
                        child: Hive.box('userBox').get('profileImageBase64') ==
                                null
                            ? Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 15),
                    // Username
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    // Level and Title Badge
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech_rounded,
                                color: Colors.amber[300],
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LVL',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$level',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Drawer items with modern design
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  text: 'Home',
                  color: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble_rounded,
                  text: 'Abo Layla',
                  color: accentColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboLayla()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.quiz_rounded,
                  text: 'Quiz Time',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.videogame_asset_rounded,
                  text: 'Gamification',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.leaderboard_rounded,
                  text: 'Leaderboard',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameLeaderBoard()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.work_rounded,
                  text: 'Career Mode',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CareerHome()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.insights_rounded,
                  text: 'Insights',
                  color: Colors.pink,
                  onTap: () => context.push(AppRoutes.performance),
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_month_rounded,
                  text: 'Schedule',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScheduleView()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  text: 'Settings',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_rounded,
                  text: 'Help',
                  color: Colors.teal,
                  onTap: () => context.push(AppRoutes.otp),
                ),
                _buildDrawerItem(
                  icon: Icons.dark_mode_rounded,
                  text: 'Dark Mode',
                  color: Colors.deepPurple,
                  onTap: () {
                    final isDarkMode = themeManager.themeData == ThemeMode.dark;
                    themeManager.toggleTheme(!isDarkMode);
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(thickness: 1),
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  text: 'Logout',
                  color: Colors.red,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required Color color,
    required GestureTapCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      Color primaryColor, Color secondaryColor, Color accentColor) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: GNav(
          gap: 8,
          activeColor: primaryColor,
          color: Colors.white.withOpacity(0.7),
          iconSize: 26,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: Duration(milliseconds: 500),
          tabBackgroundColor: Colors.white,
          tabBorderRadius: 20,
          curve: Curves.easeInOutCubic,
          tabs: [
            GButton(
              icon: Ionicons.home,
              text: 'Home',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            GButton(
              icon: Ionicons.book,
              text: 'Courses',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            GButton(
              icon: Ionicons.chatbubble_ellipses,
              text: 'Abo Layla',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            GButton(
              icon: Ionicons.trophy,
              text: 'Board',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
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
