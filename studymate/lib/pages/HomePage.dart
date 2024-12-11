// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Homebody.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/ProfilePage.dart';
import 'package:studymate/pages/Settings.dart';
import 'package:studymate/pages/ScheduleManager.dart';
import '../Classes/User.dart';
import 'package:studymate/pages/AboLayla/AboLayla.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../util/TextField.dart';



import '../Pop-ups/PopUps_Success.dart';
import '../Pop-ups/PopUps_Failed.dart';
import '../Pop-ups/PopUps_Warning.dart';
import 'Resources.dart';

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

  int idx = 0 ;
void navBottom(int index){
  setState((){
    idx = index ; 
  });
}
  final List<Widget> pages = [ 
    Homebody(),
    Resources(),
    AboLayla(),
    AboLayla(),
  ];

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
    print("mahdy was here ${UserID}");
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
                    showSuccessPopup(context, 'title', 'message');
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
                        MaterialPageRoute(builder: (context) => Profilepage(user: widget.user,)));
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
              leading: Icon(Icons.schedule),
              title: Text('Schedule'),
              onTap: () {
                // Handle the Close tap
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

      body:pages[idx],

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