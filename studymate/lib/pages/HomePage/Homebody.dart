import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Resuorces/SRS.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Homebody extends StatefulWidget {
  const Homebody({super.key});
  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody> {
  // Define branding colors
  final Color primaryColor = Color(0xFF1c74bb); // Blue 1
  final Color secondaryColor = Color(0xFF165d96); // Blue 2
  final Color accentColor = Color(0xFF18bebc); // Cyan 1
  final Color accentColor2 = Color(0xFF139896); // Cyan 2

  // Data variables
  List<dynamic> _events = [];
  bool _isLoading = true;

  List<String> courses = [];
  List<String> coursesIndex = [];

  List<dynamic> _recentQuizzes = [];
  bool _isLoadingQuizzes = true;

  @override
  void initState() {
    super.initState();
    _fetchTodaysSchedule();
    _fetchRecentCourses();
    _fetchRecentQuizzes();
  }

  // Fetch today's schedule
  Future<void> _fetchTodaysSchedule() async {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    int userID = Hive.box('userBox').get('id');

    try {
      final response = await http.get(Uri.parse(
          'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userID&start_date=$formattedDate&end_date=$formattedDate'));

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _events = [];
        });
        print(
            'Failed to fetch today\'s schedule with status code ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching today's schedule: $e");
      setState(() {
        _isLoading = false;
        _events = [];
      });
    }
  }

  // Fetch recent courses
  Future<void> _fetchRecentCourses() async {
    const url =
        'https://alyibrahim.pythonanywhere.com/recentCourses'; // Replace with your actual Flask server URL
    final username = Hive.box('userBox').get('username');
    print("USERNAME: $username");
    final Map<String, dynamic> requestBody = {
      'username': username,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          courses = jsonResponse['courses'].cast<String>();
          coursesIndex = (jsonResponse['CourseID'] as List)
              .map((item) => item['COId'].toString())
              .toList();
        });
      } else {
        print('Request failed with status: ${response.body}.');
      }
    } catch (e) {
      print("Error fetching recent courses: $e");
    }
  }

  // Fetch recent quizzes
  Future<void> _fetchRecentQuizzes() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_recent_quizzes';
    int userID = Hive.box('userBox').get('id');
    try {
      final response = await http.get(
        Uri.parse('$url?user_id=$userID'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _recentQuizzes = jsonResponse['quizzes'];
            _isLoadingQuizzes = false;
          });
        } else {
          setState(() {
            _isLoadingQuizzes = false;
            _recentQuizzes = [];
          });
          print('Failed to fetch recent quizzes: ${jsonResponse['message']}');
        }
      } else {
        setState(() {
          _isLoadingQuizzes = false;
          _recentQuizzes = [];
        });
        print(
            'Failed to fetch recent quizzes with status code ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching recent quizzes: $e");
      setState(() {
        _isLoadingQuizzes = false;
        _recentQuizzes = [];
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          _buildGreetingSection(),
          SizedBox(height: 20),
          // Today's Schedule
          _buildSectionHeader('Today\'s Schedule', onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScheduleView()),
            );
          }),
          SizedBox(height: 15),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks for today.',
                        style: TextStyle(fontSize: 18, color: secondaryColor),
                      ),
                    )
                  : _buildScheduleCards(),
          SizedBox(height: 30),
          // Recent Courses
          _buildSectionHeader('Recent Courses', onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Resources()),
            );
          }),
          SizedBox(height: 15),
          courses.isEmpty
              ? Center(
                  child: Text(
                    'No recent courses.',
                    style: TextStyle(fontSize: 18, color: secondaryColor),
                  ),
                )
              : _buildCoursesList(),
          SizedBox(height: 30),
          // Recent Quizzes
          _buildSectionHeader('Recent Quizzes', onViewAll: () {
            // Navigate to quizzes page
            // Navigator.pushNamed(context, '/QuizzesPage');
          }),
          SizedBox(height: 15),
          _isLoadingQuizzes
              ? Center(child: CircularProgressIndicator())
              : _recentQuizzes.isEmpty
                  ? Center(
                      child: Text(
                        'No recent quizzes.',
                        style: TextStyle(fontSize: 18, color: secondaryColor),
                      ),
                    )
                  : _buildQuizzesList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    final username = Hive.box('userBox').get('username') ?? 'User';
    final currentHour = DateTime.now().hour;
    String greeting = '';

    if (currentHour < 12) {
      greeting = 'Good Morning,';
    } else if (currentHour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return Text(
      '$greeting $username!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 16,
                  color: accentColor,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: accentColor,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCards() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: _getEventCardColor(event['Type']),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['Title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatTime(event['StartTime'] ?? 'Unknown Time'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getEventCardColor(String? type) {
    switch (type) {
      case 'Lecture':
        return primaryColor;
      case 'Assignment':
        return accentColor2;
      case 'Exam':
        return Colors.redAccent;
      default:
        return secondaryColor;
    }
  }

  Widget _buildCoursesList() {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final courseName = courses[index];
          final courseId = coursesIndex[index];
          return GestureDetector(
            onTap: () {
              Hive.box('userBox').put('COId', courseId);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseContent()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                children: [
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(_getCourseBackgroundImage(index)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          courseName,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black38,
                              ),
                            ],
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
      ),
    );
  }

  String _getCourseBackgroundImage(int index) {
    final List<String> images = [
      'lib/assets/img/bg1.jpg',
      'lib/assets/img/bg2.jpg',
      'lib/assets/img/bg3.jpg',
      'lib/assets/img/bg4.jpg',
      'lib/assets/img/bg5.jpg',
      'lib/assets/img/bg6.jpg',
      'lib/assets/img/bg7.jpg',
      'lib/assets/img/bg8.jpg',
    ];
    return images[index % images.length];
  }

  Widget _buildQuizzesList() {
    return Column(
      children: _recentQuizzes.map((quiz) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                Icons.quiz_outlined,
                color: Colors.white,
                size: 40,
              ),
              title: Text(
                quiz['QuizTitle'] ?? 'Quiz ${quiz['QID']}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${quiz['Score'] ?? 'N/A'} / ${quiz['TotalScore'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Navigate to quiz details
                  // int quizId = quiz['QID'];
                  // Navigator.pushNamed(context, '/QuizDetail', arguments: {'quizId': quizId});
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}