import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class InsightsPage extends StatefulWidget {
  // Retrieve the user's name from Hive
  final String userName = Hive.box('userBox').get('username') ?? 'User';

  InsightsPage({Key? key}) : super(key: key);

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int totalQuizzesTaken = 0; // Initialize to 0
  double averageScore = 0.0; // Initialize to 0.0
  int activeStreak = 0; // Initialize to 0
  bool isLoading = true; // Flag to show loading indicator
  int? id;
  Map<String, int> numberOfSolvedQuestionsInCourse = {};
  Map<String, int> coursesID = {};

  List<String> courses = [];

  @override
  void initState() {
    super.initState();
    id = Hive.box('userBox').get('id');
    getInsights();
    getCourses();
  }

  Future<void> getCourses() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_courses_answered';
    if (id == null) {
      // Handle the case where id is null
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

        setState(() {
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

        setState(() {
          totalQuizzesTaken = responseData['total_quizzes'] ?? 0;
          averageScore = (responseData['average_score'] ?? 0.0).toDouble();
          activeStreak = responseData['day_streak'] ?? 0;
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

  // Widget for Key Metrics Card
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom titles for the chart (unused in current code but kept for reference)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Mon', style: style);
        break;
      case 2:
        text = Text('Tue', style: style);
        break;
      case 3:
        text = Text('Wed', style: style);
        break;
      case 4:
        text = Text('Thu', style: style);
        break;
      case 5:
        text = Text('Fri', style: style);
        break;
      case 6:
        text = Text('Sat', style: style);
        break;
      case 7:
        text = Text('Sun', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 4.0, child: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF165D96),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : (courses.isEmpty
              ? Center(
                  child: Text('No data available.'),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with user's name
                        Text(
                          'Hello, ${widget.userName}! Here\'s an overview of your learning journey.',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        // Key Metrics Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricCard(
                              title: 'Total Quizzes Taken',
                              value: totalQuizzesTaken.toString(),
                              icon: Icons.assignment,
                            ),
                            _buildMetricCard(
                              title: 'Average Score',
                              value: '${averageScore.toStringAsFixed(1)}%',
                              icon: Icons.score,
                            ),
                            _buildMetricCard(
                              title: 'Active Streak',
                              value: '$activeStreak days',
                              icon: Icons.whatshot,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Quizzes Completed by Course',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 40),
                        totalQuizzes == 0
                            ? Center(
                                child: Text('No quiz data to display.'),
                              )
                            : SizedBox(
                                height: 250,
                                child: Column(
                                  children: [
                                    Expanded(
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
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$totalQuizzesTaken',
                                                style: TextStyle(
                                                    fontSize: 36,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Quizzes Completed',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // Legend
                                  ],
                                ),
                              ),
                        SizedBox(height: 40),
                        Center(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              for (int i = 0; i < topCourses.length; i++)
                                Indicator(
                                  color: colorsList[i % colorsList.length],
                                  text: topCourses[i].key,
                                  isSquare: true,
                                ),
                              if (otherSum > 0)
                                Indicator(
                                  color: colorsList[5 % colorsList.length],
                                  text: 'Other',
                                  isSquare: true,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        // Course Insights Section
                        Text(
                          'Your Courses',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: courses.map((course) {
                            // Safely retrieve courseID and quizzesCompleted
                            int courseId = coursesID[course] ?? 0;
                            int quizzesCompleted =
                                numberOfSolvedQuestionsInCourse[course] ?? 0;

                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.book),
                                title: Text(course),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to Course Insights Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseInsightsPage(
                                        courseName: course,
                                        courseID: courseId.toString(),
                                        totalQuizzesTaken: quizzesCompleted,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }
}

// Course Insights Page
class CourseInsightsPage extends StatefulWidget {
  final String courseName;
  final String courseID;
  final int? totalQuizzesTaken;

  CourseInsightsPage({
    required this.courseName,
    required this.courseID,
    required this.totalQuizzesTaken,
  });

  @override
  State<CourseInsightsPage> createState() => _CourseInsightsPageState();
}

class _CourseInsightsPageState extends State<CourseInsightsPage> {
  double averageScore = 0.0;
  int totalQuizzesTaken = 0;
  int solvedQuestions = 0;
  int totalQuestions = 0;
  bool isLoading = true;

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
    fetchCourseInsights();
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
    return Card(
      elevation: 3,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
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
        ),
        SizedBox(width: 10),
        Indicator(
          color: colorsList[1],
          text: 'Unsolved Questions',
          isSquare: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Avoid potential division by zero
    String solvedQuestionsText = solvedQuestions.toString();
    String totalQuestionsText = totalQuestions.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.courseName} Insights',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF165D96),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (totalQuestions == 0
              ? Center(
                  child: Text('No data available for this course.'),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      // Key Metrics
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course Overview',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricCard(
                              title: 'Quizzes Taken',
                              value: totalQuizzesTaken.toString(),
                              icon: Icons.assignment,
                            ),
                            _buildMetricCard(
                              title: 'Average Score',
                              value: '${averageScore.toStringAsFixed(1)}%',
                              icon: Icons.score,
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Questions Progress',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 40),
                        // Pie Chart for Solved vs Unsolved Questions
                        SizedBox(
                          height: 250,
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sections: pieSections,
                                        centerSpaceRadius: 90,
                                        sectionsSpace: 3,
                                        startDegreeOffset: -90,
                                        borderData: FlBorderData(show: false),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$solvedQuestionsText / $totalQuestionsText',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Questions Solved',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // Legend
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        _buildLegend(),
                        // Add more sections such as recent quizzes or performance trends if needed
                      ],
                    ),
                  ),
                )),
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
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor = Colors.black,
  }) : super(key: key);

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
