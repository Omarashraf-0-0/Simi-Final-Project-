import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Homebody extends StatefulWidget {
  const Homebody({super.key});
  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody> {
  // Brand colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color accentColor2 = const Color(0xFF139896);

  // State variables
  List<dynamic> _events = [];
  List<String> courses = [];
  List<String> coursesIndex = [];
  List<dynamic> _recentQuizzes = [];
  bool _isLoading = true;
  bool _isLoadingQuizzes = true;
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Loading shimmer effect
  Widget _buildLoadingShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: child,
    );
  }

  // Schedule Loader Card
  Widget _buildScheduleLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: _buildLoadingShimmer(
        child: Container(
          width: 200,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Courses Loader Card
  Widget _buildCoursesLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: _buildLoadingShimmer(
        child: Container(
          width: 250,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Container(
                width: 250,
                height: 180,
                color: Colors.white,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  width: 150,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quizzes Loader Card
  Widget _buildQuizzesLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildLoadingShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            title: Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              width: 60,
              height: 16,
              color: Colors.white,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Load all data on init
  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchTodaysSchedule(),
        _fetchRecentCourses(),
        _fetchRecentQuizzes()
      ]);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section
          _buildGreeting(),
          const SizedBox(height: 20),

          // Schedule section
          _buildSectionHeader('Today\'s Schedule',
              onViewAll: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ScheduleView()))),
          const SizedBox(height: 15),
          _isLoading
              ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, __) => _buildScheduleLoaderCard(),
                  ),
                )
              : _buildScheduleSection(),
          const SizedBox(height: 30),

          // Courses section
          _buildSectionHeader('Recent Courses',
              onViewAll: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Resources()))),
          const SizedBox(height: 15),
          _isLoadingCourses
              ? SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, __) => _buildCoursesLoaderCard(),
                  ),
                )
              : _buildCoursesSection(),
          const SizedBox(height: 30),

          // Quizzes section
          _buildSectionHeader('Recent Quizzes'),
          const SizedBox(height: 15),
          _isLoadingQuizzes
              ? Column(
                  children: List.generate(3, (_) => _buildQuizzesLoaderCard()),
                )
              : _buildQuizzesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fetch methods and other widgets remain the same...

  // Format time string to 12-hour format
  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Get background image for course card
  String _getCourseBackgroundImage(int index) {
    final images = [
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

  // Get color for event card based on type
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

  Widget _buildGreeting() {
    final username = Hive.box('userBox').get('username') ?? 'User';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning,'
        : hour < 17
            ? 'Good Afternoon,'
            : 'Good Evening,';

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
        if (onViewAll != null)
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

  Widget _buildScheduleSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Text(
          'No tasks for today.',
          style: TextStyle(fontSize: 18, color: secondaryColor),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: _getEventCardColor(event['Type']),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['Title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(event['StartTime'] ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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

  // Color _getEventCardColor(String? type) {
  //   switch (type) {
  //     case 'Lecture':
  //       return primaryColor;
  //     case 'Assignment':
  //       return accentColor2;
  //     case 'Exam':
  //       return Colors.redAccent;
  //     default:
  //       return secondaryColor;
  //   }
  // }

  // Widget _buildCoursesList() {
  //   return SizedBox(
  Widget _buildCoursesSection() {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No recent courses.',
          style: TextStyle(fontSize: 18, color: secondaryColor),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Hive.box('userBox').put('COId', coursesIndex[index]);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseContent()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
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
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      courses[index],
                      style: const TextStyle(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizzesSection() {
    if (_isLoadingQuizzes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentQuizzes.isEmpty) {
      return Center(
        child: Text(
          'No recent quizzes.',
          style: TextStyle(fontSize: 18, color: secondaryColor),
        ),
      );
    }

    return Column(
      children: _recentQuizzes.map((quiz) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                Icons.quiz_outlined,
                color: Theme.of(context).colorScheme.surface,
                size: 40,
              ),
              title: Text(
                quiz['QuizTitle'] ?? 'Quiz ${quiz['QID']}',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${quiz['Score'] ?? 'N/A'} / ${quiz['TotalScore'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Update fetch methods to handle loading states

  Future<void> _fetchTodaysSchedule() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final userID = Hive.box('userBox').get('id');
      final url =
          'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userID&start_date=$today&end_date=$today';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _events = [];
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchRecentCourses() async {
    try {
      final username = Hive.box('userBox').get('username');
      final response = await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/recentCourses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          courses = List<String>.from(data['courses']);
          coursesIndex = (data['CourseID'] as List)
              .map((item) => item['COId'].toString())
              .toList();
          _isLoadingCourses = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchRecentQuizzes() async {
    try {
      final userID = Hive.box('userBox').get('id');
      final response = await http.get(
        Uri.parse(
            'https://alyibrahim.pythonanywhere.com/get_recent_quizzes?user_id=$userID'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _recentQuizzes = data['quizzes'];
            _isLoadingQuizzes = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load quizzes');
      }
    } catch (e) {
      setState(() {
        _isLoadingQuizzes = false;
        _recentQuizzes = [];
      });
      print('Error: $e');
    }
  }
}
