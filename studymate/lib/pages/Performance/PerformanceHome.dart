import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../models/recommendation_models.dart';
import '../../services/recommendation_service.dart';

class InsightsPage extends StatefulWidget {
  // Retrieve the user's name from Hive
  final String userName = Hive.box('userBox').get('username') ?? 'User';

  InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with SingleTickerProviderStateMixin {
  int totalQuizzesTaken = 0; // Initialize to 0
  double averageScore = 0.0; // Initialize to 0.0
  int activeStreak = 0; // Initialize to 0
  bool isLoading = true; // Flag to show loading indicator
  int? id;
  Map<String, int> numberOfSolvedQuestionsInCourse = {};
  Map<String, int> coursesID = {};

  List<String> courses = [];

  // Recommendation system variables
  final RecommendationService _recommendationService = RecommendationService();
  List<WeakTopic> weakTopics = [];
  bool isLoadingRecommendations = false;
  bool recommendationsError = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    id = Hive.box('userBox').get('id');
    getInsights();
    getCourses();
    // Load weak topics for recommendations
    _loadWeakTopics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load weak topics from the backend
  Future<void> _loadWeakTopics() async {
    if (id == null) return;

    if (!mounted) return;
    setState(() {
      isLoadingRecommendations = true;
      recommendationsError = false;
    });

    try {
      // Get the first course ID if available
      if (coursesID.isNotEmpty) {
        final firstCourseId = coursesID.values.first;

        final topics = await _recommendationService.getWeakTopics(
          userId: id!,
          courseId: firstCourseId,
          threshold: 60.0, // Topics below 60% accuracy
        );

        if (!mounted) return;
        setState(() {
          weakTopics = topics;
          isLoadingRecommendations = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      print('Error loading weak topics: $e');
      if (!mounted) return;
      setState(() {
        recommendationsError = true;
        isLoadingRecommendations = false;
      });
    }
  }

  Future<void> getCourses() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_courses_answered';
    if (id == null) {
      // Handle the case where id is null
      print('User ID is null');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String body = jsonEncode({
      'ID': id.toString(),
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);

        // Clear the existing data
        numberOfSolvedQuestionsInCourse.clear();
        coursesID.clear();
        courses.clear();

        // Process the list of courses
        for (var courseData in responseData) {
          String courseName = courseData['COName'] ?? 'Unknown Course';
          int quizzesCompleted = courseData['NumberOfQuizzes'] ?? 0;
          int courseID = courseData['co_id'] ?? 0;

          // Avoid duplicates
          if (!courses.contains(courseName)) {
            numberOfSolvedQuestionsInCourse[courseName] = quizzesCompleted;
            coursesID[courseName] = courseID;
            courses.add(courseName);
          }
        }
        // After updating the data, prepare the pie chart
        preparePieChartData();

        if (!mounted) return;
        setState(() {
          isLoading = false;
        });

        // Load recommendations after courses are loaded
        _loadWeakTopics();
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('An exception occurred: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  int totalQuizzes = 0;
  List<MapEntry<String, int>> topCourses = [];
  int otherSum = 0;
  List<PieChartSectionData> pieSections = [];
  List<Color> colorsList = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange, // Color for "Other"
  ];

  // Method to prepare data for the pie chart
  void preparePieChartData() {
    // Calculate the total number of quizzes
    totalQuizzes = numberOfSolvedQuestionsInCourse.values
        .fold(0, (sum, item) => sum + item);

    if (totalQuizzes == 0) {
      // Avoid division by zero
      pieSections = [];
      return;
    }

    // Sort courses by the number of solved questions in descending order
    List<MapEntry<String, int>> sortedCourses =
        numberOfSolvedQuestionsInCourse.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Take the top 5 courses
    topCourses = sortedCourses.take(5).toList();
    List<MapEntry<String, int>> otherCourses = sortedCourses.skip(5).toList();

    // Sum up the "Other" courses
    otherSum = otherCourses.fold(0, (sum, entry) => sum + entry.value);

    // Prepare the PieChart sections
    pieSections = [];

    for (int i = 0; i < topCourses.length; i++) {
      final course = topCourses[i];
      final value = course.value.toDouble();
      final color = colorsList[i % colorsList.length];

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: value,
          showTitle: false,
          radius: 50,
        ),
      );
    }

    if (otherSum > 0) {
      final value = otherSum.toDouble();
      final color = colorsList[5 % colorsList.length]; // Color for "Other"

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: value,
          showTitle: false,
          radius: 50,
        ),
      );
    }
  }

  // Function to fetch insights from the backend
  Future<void> getInsights() async {
    const String url = 'https://alyibrahim.pythonanywhere.com/get_insights';
    if (id == null) {
      // Handle the case where id is null
      print('User ID is null');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String body = jsonEncode({
      'ID': id.toString(),
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (!mounted) return;
        setState(() {
          totalQuizzesTaken = responseData['total_quizzes'] ?? 0;
          averageScore = (responseData['average_score'] ?? 0.0).toDouble();
          activeStreak = responseData['day_streak'] ?? 0;
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('An exception occurred: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Widget for Key Metrics Card
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1c74bb),
              const Color(0xFF18bebc),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1c74bb).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Summary Item Widget
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // AI Recommendations Section
  Widget _buildRecommendationsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1c74bb).withOpacity(0.1),
            Color(0xFF18bebc).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF1c74bb).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1c74bb), Color(0xFF18bebc)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1c74bb),
                      ),
                    ),
                    Text(
                      'Personalized suggestions based on your performance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoadingRecommendations && !recommendationsError)
                IconButton(
                  icon: Icon(Icons.refresh, color: Color(0xFF1c74bb)),
                  onPressed: _loadWeakTopics,
                ),
            ],
          ),
          SizedBox(height: 16),

          // Content
          if (isLoadingRecommendations)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF1c74bb)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Analyzing your performance...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else if (recommendationsError)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.orange, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Could not load recommendations',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _loadWeakTopics,
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1c74bb),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (weakTopics.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.green,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Great job! No weak areas found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Keep up the excellent work! Complete more quizzes to get personalized insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: weakTopics.take(3).map((topic) {
                return _buildWeakTopicCard(topic);
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Individual weak topic card
  Widget _buildWeakTopicCard(WeakTopic topic) {
    final accuracyColor = topic.accuracy < 40
        ? Colors.red
        : topic.accuracy < 60
            ? Colors.orange
            : Colors.yellow[700]!;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accuracyColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Accuracy indicator
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accuracyColor.withOpacity(0.2),
                    border: Border.all(color: accuracyColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${topic.accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: accuracyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Topic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.topic,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1c74bb),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lectures: ${topic.lectures.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${topic.correctCount}/${topic.totalCount} correct',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Warning icon
                Icon(
                  Icons.warning_amber_rounded,
                  color: accuracyColor,
                  size: 24,
                ),
              ],
            ),

            // Recommendation message
            if (topic.accuracy < 60)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF18bebc).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF18bebc),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Review lecture materials and practice more questions on this topic',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF165d96),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1c74bb),
                    Color(0xFF165d96),
                    Color(0xFF18bebc),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1c74bb)),
                        strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Loading Your Insights...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Analyzing your performance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : courses.isEmpty
              ? const Center(child: Text('No data available.'))
              : CustomScrollView(
                  slivers: [
                    // Gradient SliverAppBar
                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      foregroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1c74bb),
                                Color(0xFF165d96),
                                Color(0xFF18bebc),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.insights,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Performance Insights",
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Hi, ${widget.userName}!",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
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
                            ],
                          ),
                        ),
                      ),
                      backgroundColor: const Color(0xFF1c74bb),
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // Key Metrics with animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  final clampedValue = value.clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: clampedValue,
                                    child: Opacity(
                                        opacity: clampedValue, child: child),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMetricCard(
                                      title: 'Total Quizzes',
                                      value: totalQuizzesTaken.toString(),
                                      icon: Icons.assignment,
                                    ),
                                    _buildMetricCard(
                                      title: 'Average Score',
                                      value:
                                          '${averageScore.toStringAsFixed(1)}%',
                                      icon: Icons.score,
                                    ),
                                    _buildMetricCard(
                                      title: 'Active Streak',
                                      value: '$activeStreak days',
                                      icon: Icons.whatshot,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Course Performance Overview Title
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.bar_chart_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Course Performance',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1c74bb),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              totalQuizzes == 0
                                  ? Center(
                                      child: Container(
                                        padding: EdgeInsets.all(40),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1c74bb)
                                                  .withOpacity(0.1),
                                              Color(0xFF18bebc)
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.quiz_outlined,
                                              size: 60,
                                              color: Color(0xFF1c74bb),
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No quiz data yet',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1c74bb),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Start taking quizzes to see your progress!',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        // Top Courses Horizontal Cards
                                        SizedBox(
                                          height: 180,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: topCourses.length,
                                            itemBuilder: (context, index) {
                                              final course = topCourses[index];
                                              final quizCount = course.value;
                                              final percentage = (quizCount /
                                                      totalQuizzes *
                                                      100)
                                                  .toInt();
                                              final gradientColors = [
                                                [
                                                  Color(0xFF1c74bb),
                                                  Color(0xFF4a90e2)
                                                ],
                                                [
                                                  Color(0xFF18bebc),
                                                  Color(0xFF4ecdc4)
                                                ],
                                                [
                                                  Color(0xFF6B5CE7),
                                                  Color(0xFF9575cd)
                                                ],
                                                [
                                                  Color(0xFFFF6B9D),
                                                  Color(0xFFff8fab)
                                                ],
                                                [
                                                  Color(0xFFFFA500),
                                                  Color(0xFFffb84d)
                                                ],
                                              ];

                                              return Container(
                                                width: 160,
                                                margin: EdgeInsets.only(
                                                    right: 15,
                                                    left: index == 0 ? 0 : 0),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: gradientColors[
                                                        index %
                                                            gradientColors
                                                                .length],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: gradientColors[
                                                              index %
                                                                  gradientColors
                                                                      .length][0]
                                                          .withOpacity(0.3),
                                                      blurRadius: 15,
                                                      offset: Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CourseInsightsPage(
                                                            courseID: coursesID[
                                                                    course.key]!
                                                                .toString(),
                                                            courseName:
                                                                course.key,
                                                            totalQuizzesTaken:
                                                                numberOfSolvedQuestionsInCourse[
                                                                    course
                                                                        .key]!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.25),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .book_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                          SizedBox(height: 12),
                                                          Expanded(
                                                            child: Text(
                                                              course.key,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                height: 1.2,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Text(
                                                                  '$quizCount Quizzes',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            '$percentage%',
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (otherSum > 0) ...[
                                          SizedBox(height: 20),
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF00C9A7)
                                                      .withOpacity(0.1),
                                                  Color(0xFF00C9A7)
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: Color(0xFF00C9A7)
                                                    .withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF00C9A7)
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Icon(
                                                    Icons.more_horiz_rounded,
                                                    color: Color(0xFF00C9A7),
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Other Courses',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF00C9A7),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$otherSum more quizzes across other courses',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF00C9A7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Text(
                                                    '${(otherSum / totalQuizzes * 100).toInt()}%',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 20),
                                        // Summary Stats
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1c74bb)
                                                    .withOpacity(0.05),
                                                Color(0xFF18bebc)
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildSummaryItem(
                                                icon: Icons.bar_chart_rounded,
                                                label: 'Total Quizzes',
                                                value: totalQuizzesTaken
                                                    .toString(),
                                                color: Color(0xFF1c74bb),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 40,
                                                color: Colors.grey.shade300,
                                              ),
                                              _buildSummaryItem(
                                                icon: Icons.school_rounded,
                                                label: 'Active Courses',
                                                value: topCourses.length
                                                    .toString(),
                                                color: Color(0xFF18bebc),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                              const SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1c74bb).withOpacity(0.05),
                                      Color(0xFF18bebc).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    for (int i = 0; i < topCourses.length; i++)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorsList[
                                                      i % colorsList.length]
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: colorsList[
                                                    i % colorsList.length],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              topCourses[i].key,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (otherSum > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorsList[
                                                      5 % colorsList.length]
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: colorsList[
                                                    5 % colorsList.length],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Other',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 35),

                              // AI Recommendations Section (moved here)
                              _buildRecommendationsSection(),

                              SizedBox(height: 30),

                              // Course Insights Section
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1c74bb),
                                          Color(0xFF18bebc)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Your Courses',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1c74bb),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Column(
                                children: courses.map((course) {
                                  // Safely retrieve courseID and quizzesCompleted
                                  int courseId = coursesID[course] ?? 0;
                                  int quizzesCompleted =
                                      numberOfSolvedQuestionsInCourse[course] ??
                                          0;

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.white,
                                          const Color(0xFF1c74bb)
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.15),
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () {
                                          // Navigate to Course Insights Page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CourseInsightsPage(
                                                courseName: course,
                                                courseID: courseId.toString(),
                                                totalQuizzesTaken:
                                                    quizzesCompleted,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF1c74bb),
                                                      const Color(0xFF18bebc),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      course,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      '$quizzesCompleted quizzes completed',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: const Color(0xFF1c74bb),
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Course Insights Page
class CourseInsightsPage extends StatefulWidget {
  final String courseName;
  final String courseID;
  final int? totalQuizzesTaken;

  const CourseInsightsPage({
    super.key,
    required this.courseName,
    required this.courseID,
    required this.totalQuizzesTaken,
  });

  @override
  State<CourseInsightsPage> createState() => _CourseInsightsPageState();
}

class _CourseInsightsPageState extends State<CourseInsightsPage>
    with SingleTickerProviderStateMixin {
  double averageScore = 0.0;
  int totalQuizzesTaken = 0;
  int solvedQuestions = 0;
  int totalQuestions = 0;
  bool isLoading = true;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Data for the pie chart
  List<PieChartSectionData> pieSections = [];
  List<Color> colorsList = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange, // Color for "Other"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    fetchCourseInsights();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchCourseInsights() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_course_insights';
    int? userId = Hive.box('userBox').get('id');
    String courseId = widget.courseID;

    if (userId == null) {
      print('User ID is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String body = jsonEncode({
      'ID': userId,
      'co_id': courseId,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          totalQuizzesTaken = responseData['total_quizzes_taken'] ?? 0;
          averageScore = (responseData['average_score'] ?? 0.0).toDouble();
          solvedQuestions = responseData['solved_questions'] ?? 0;
          totalQuestions = responseData['total_questions'] ?? 0;

          // Prepare the Pie Chart data after fetching the data
          preparePieChartData();
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('An exception occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Prepare data for Pie Chart
  void preparePieChartData() {
    pieSections = [];

    double solvedValue = solvedQuestions.toDouble();
    double unsolvedValue = (totalQuestions - solvedQuestions).toDouble();

    // Ensure values are non-negative
    if (solvedValue < 0) solvedValue = 0;
    if (unsolvedValue < 0) unsolvedValue = 0;

    // Handle the case when totalQuestions is zero to avoid division by zero
    if (solvedValue + unsolvedValue == 0) {
      pieSections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          showTitle: false,
          radius: 50,
        ),
      );
    } else {
      // Solved Questions Section
      pieSections.add(
        PieChartSectionData(
          color: colorsList[0],
          value: solvedValue,
          showTitle: false,
          radius: 50,
        ),
      );

      // Unsolved Questions Section
      pieSections.add(
        PieChartSectionData(
          color: colorsList[1],
          value: unsolvedValue,
          showTitle: false,
          radius: 50,
        ),
      );
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1c74bb),
              const Color(0xFF18bebc),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1c74bb).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Indicator(
          color: colorsList[0],
          text: 'Solved Questions',
          isSquare: true,
          textColor: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        SizedBox(width: 10),
        Indicator(
          color: colorsList[1],
          text: 'Unsolved Questions',
          isSquare: true,
          textColor: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String solvedQuestionsText = solvedQuestions.toString();
    String totalQuestionsText = totalQuestions.toString();
    double progress =
        totalQuestions > 0 ? (solvedQuestions / totalQuestions) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1c74bb),
                    Color(0xFF165d96),
                    Color(0xFF18bebc),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1c74bb)),
                        strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Loading Course Data...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Preparing your insights',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : totalQuestions == 0
              ? Center(child: Text('No data available for this course.'))
              : CustomScrollView(
                  slivers: [
                    // Gradient SliverAppBar
                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      iconTheme: IconThemeData(color: Colors.white),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          widget.courseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1c74bb),
                                Color(0xFF165d96),
                                Color(0xFF18bebc),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 60,
                                left: 20,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${(progress * 100).toStringAsFixed(0)}% Complete',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      backgroundColor: const Color(0xFF1c74bb),
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // Course Overview Title
                              Text(
                                'Course Overview',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Key Metrics with animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  final clampedValue = value.clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: clampedValue,
                                    child: Opacity(
                                        opacity: clampedValue, child: child),
                                  );
                                },
                                child: Row(
                                  children: [
                                    _buildMetricCard(
                                      title: 'Quizzes Taken',
                                      value: totalQuizzesTaken.toString(),
                                      icon: Icons.assignment_turned_in,
                                    ),
                                    _buildMetricCard(
                                      title: 'Average Score',
                                      value:
                                          '${averageScore.toStringAsFixed(1)}%',
                                      icon: Icons.trending_up,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Questions Progress Section
                              Text(
                                'Questions Progress',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Pie Chart Container
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 250,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          PieChart(
                                            PieChartData(
                                              sections: pieSections,
                                              centerSpaceRadius: 90,
                                              sectionsSpace: 3,
                                              startDegreeOffset: -90,
                                              borderData:
                                                  FlBorderData(show: false),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  const Color(0xFF1c74bb)
                                                      .withOpacity(0.1),
                                                  const Color(0xFF18bebc)
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '$solvedQuestionsText / $totalQuestionsText',
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFF1c74bb),
                                                  ),
                                                ),
                                                Text(
                                                  'Questions',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    _buildLegend(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),

                              // Progress Bar Section
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1c74bb).withOpacity(0.1),
                                      Color(0xFF18bebc).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Color(0xFF1c74bb).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Overall Progress',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1c74bb),
                                          ),
                                        ),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF18bebc),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: TweenAnimationBuilder<double>(
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        tween: Tween(begin: 0.0, end: progress),
                                        curve: Curves.easeInOut,
                                        builder: (context, value, child) {
                                          return LinearProgressIndicator(
                                            value: value,
                                            minHeight: 12,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF18bebc),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      solvedQuestions == totalQuestions
                                          ? '🎉 Excellent! You\'ve completed all questions!'
                                          : 'Keep going! ${totalQuestions - solvedQuestions} more to go!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
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
                  ],
                ),
    );
  }
}

// Indicator widget for the legend
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        )
      ],
    );
  }
}
