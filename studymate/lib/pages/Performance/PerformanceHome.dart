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
  int activeStreak = 5; // You can update this with actual data if available
  bool isLoading = true; // Flag to show loading indicator
  int id = Hive.box('userBox').get('id');
  Map<String, int> numberOfSolvedQuestionsInCourse = {};
  Map<String, int> coursesID = {};

  List<String> courses = [];

  Future<void> get_courses() async {
    const url =
        'https://alyibrahim.pythonanywhere.com/get_courses_answered'; // Replace with your actual Flask server URL
    int id = Hive.box('userBox').get('id');
    // Ensure the headers are set to accept and send JSON
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    // Convert the id to a JSON string
    String body = jsonEncode({
      'ID': id.toString(),
    });
    // Send a POST request to the server with the JSON body
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    // Check if the response is successful
    if (response.statusCode == 200) {
      // print('Response: ${response.body}');
      // If the server returns a 200 OK response, then parse the JSON response
      List<dynamic> responseData = jsonDecode(response.body);
      // Clear the existing data
      // print('Response Data: $responseData');
      numberOfSolvedQuestionsInCourse.clear();
      // Process the list of courses
      for (var courseData in responseData) {
        print('Course Data: $courseData');
        print('Course Name: ${courseData['COName']}');
        print('Quizzes Completed: ${courseData['NumberOfQuizzes']}');
        print('Course ID: ${courseData['co_id']}');
        String courseName = courseData['COName'];
        int quizzesCompleted = courseData['NumberOfQuizzes'];
        numberOfSolvedQuestionsInCourse[courseName] = quizzesCompleted;
        int courseID = courseData['co_id'];
        coursesID[courseName] = courseID;
        courses.add(courseName);
      }
      // After updating the data, prepare the pie chart
      preparePieChartData();

      // Update the state with the fetched data
      setState(() {
        isLoading = false;
      });
    } else {
      // Handle non-200 responses
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      // Optionally, parse the error message from response body
      Map<String, dynamic> errorData = jsonDecode(response.body);
      print('Error message: ${errorData['error']}');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Map<String, int> numberOfSolvedQuestionsInCourse = {
  //   'Mathematics 101': 22,
  //   'Biology Fundamentals': 8,
  //   'Physics Introduction': 5,
  //   'Chemistry Basics': 7,
  //   'History 101': 3,
  //   'English Literature': 4,
  //   // Add more courses as needed
  // };
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

  @override
  void initState() {
    super.initState();
    getInsights(); // Existing function to fetch insights
    preparePieChartData(); // New method to prepare pie chart data
    get_courses();
  }

  // Method to prepare data for the pie chart
  void preparePieChartData() {
    // Calculate the total number of quizzes
    totalQuizzes = numberOfSolvedQuestionsInCourse.values
        .fold(0, (sum, item) => sum + item);

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
          // title: '${((value / totalQuizzes) * 100).toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (otherSum > 0) {
      final value = otherSum.toDouble();
      final color = colorsList[5 % colorsList.length]; // Color for "Other"

      pieSections.add(
        PieChartSectionData(
          color: color,
          // value: value,
          // title: '${((value / totalQuizzes) * 100).toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }
  }

  // Function to fetch insights from the backend
  Future<void> getInsights() async {
    final String url = 'https://alyibrahim.pythonanywhere.com/get_insights';
    final int id = Hive.box('userBox').get('id');

    // Ensure the headers are set to accept and send JSON
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Construct the JSON body
    String body = jsonEncode({
      'ID': id.toString(), // Use 'ID' to match backend expectation
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Parse the JSON response body

        Map<String, dynamic> responseData = jsonDecode(response.body);

        // Update the state with the fetched data
        setState(() {
          totalQuizzesTaken = responseData['total_quizzes'] ?? 0;
          averageScore = (responseData['average_score'] ?? 0.0).toDouble();
          activeStreak = responseData['day_streak'] ?? 0;
          isLoading = false;
        });
      } else {
        // Handle non-200 responses
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        // Optionally, parse the error message from response body
        Map<String, dynamic> errorData = jsonDecode(response.body);
        print('Error message: ${errorData['error']}');

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors, JSON parsing errors)
      print('An exception occurred: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  // Sample data for performance trend; replace with actual data if available
  // List<FlSpot> performanceData = [
  //   FlSpot(1, 70),
  //   FlSpot(2, 75),
  //   FlSpot(3, 78),
  //   FlSpot(4, 80),
  //   FlSpot(5, 82),
  //   FlSpot(6, 78),
  //   FlSpot(7, 85),
  // ];

  // Sample data for courses; consider fetching this data from your backend

  // Map<String, double> courseAverageScores = {
  //   'Mathematics 101': 85.0,
  //   'Biology Fundamentals': 72.0,
  // };
  // Map<String, int> courseQuizzesCompleted = {
  //   'Mathematics 101': 12,
  //   'Biology Fundamentals': 8,
  // };
  // Map<String, int> courseTotalQuizzes = {
  //   'Mathematics 101': 15,
  //   'Biology Fundamentals': 10,
  // };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
            child: Text('Insights', style: TextStyle(color: Colors.white))),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    // Performance Trend Chart
                    // Inside your build method, under 'Performance Trend' LineChart
                    SizedBox(height: 20),
                    Text(
                      'Quizzes Completed by Course',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 40),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$totalQuizzesTaken',
                                      style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // SizedBox(height: 10,),
                                    Text(
                                      'Quizzes Completed',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(height: 140),
                          // Legend
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 20,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                      height: 80,
                    ),
                    // Course Insights Section
                    Text(
                      'Your Courses',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: courses.map((course) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.book),
                            title: Text(course),
                            // subtitle: Text(
                            //     'Average Score: ${courseAverageScores[course]?.toStringAsFixed(1)}%\nQuizzes Completed: ${courseQuizzesCompleted[course]}/${courseTotalQuizzes[course]}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to Course Insights Page
                              // print('Course: $course');
                              // print('Course ID: ${coursesID[course]}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseInsightsPage(
                                    courseName: course,
                                    courseID: coursesID[course].toString(),
                                    totalQuizzesTaken:
                                        numberOfSolvedQuestionsInCourse[course],
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
            ),
    );
  }

  // Widget for Key Metrics Card
  Widget _buildMetricCard(
      {required String title, required String value, required IconData icon}) {
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

  // Bottom titles for the chart
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
}

// Dummy Course Insights Page
class CourseInsightsPage extends StatefulWidget {
  final String courseName;
  final String courseID;
  final int? totalQuizzesTaken;

  CourseInsightsPage(
      {required this.courseName,
      required this.courseID,
      required this.totalQuizzesTaken});

  @override
  State<CourseInsightsPage> createState() => _CourseInsightsPageState();
}

class _CourseInsightsPageState extends State<CourseInsightsPage> {
  double averageScore = 0.0;
  int totalQuizzesTaken = 0;
  int solvedQuestions = 0;
  int totalQuestions = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourseInsights();
  }

  Future<void> fetchCourseInsights() async {
    const url = 'https://alyibrahim.pythonanywhere.com/get_course_insights';
    int userId = Hive.box('userBox').get('id');
    String courseId = widget.courseID;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String body = jsonEncode({
      'ID': userId,
      'co_id': courseId,
    });
    // print('Body: $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response Data: $responseData');
        setState(() {
          totalQuizzesTaken = responseData['total_quizzes_taken'] ?? 0;
          averageScore = (responseData['average_score'] ?? 0.0).toDouble();
          solvedQuestions = responseData['solved_questions'] ?? 0;
          totalQuestions = responseData['total_questions'] ?? 0;
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

  Widget _buildMetricCard(
      {required String title, required String value, required IconData icon}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        title: Center(
          child: Text(
            '${widget.courseName} Insights',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // Key Metrics
                  children: [
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
                      ],
                    ),
                    SizedBox(height: 20),
                    // Performance Trend Chart
                    Text(
                      'Performance Over Time',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // SizedBox(
                    //   height: 200,
                    //   child: LineChart(
                    //     LineChartData(
                    //       lineBarsData: [
                    //         LineChartBarData(
                    //           spots: quizAttempts.asMap().entries.map((entry) {
                    //             int index = entry.key;
                    //             Map<String, dynamic> attempt = entry.value;
                    //             return FlSpot(
                    //               index.toDouble(),
                    //               (attempt['Score'] as num).toDouble(),
                    //             );
                    //           }).toList(),
                    //           isCurved: true,
                    //           barWidth: 2,
                    //           color: Colors.blue,
                    //           dotData: FlDotData(show: true),
                    //         ),
                    //       ],
                    //       // Configure other chart properties as needed
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 20),
                    // // Quiz Attempts Table
                    // Text(
                    //   'Quiz Attempts',
                    //   style:
                    //       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // DataTable(
                    //   columns: [
                    //     DataColumn(label: Text('Quiz Name')),
                    //     DataColumn(label: Text('Score')),
                    //     DataColumn(label: Text('Date')),
                    //   ],
                    //   rows: quizAttempts.map((attempt) {
                    //     return DataRow(cells: [
                    //       DataCell(Text(attempt['quiz_name'] ?? '')),
                    //       DataCell(Text('${attempt['Score']}')),
                    //       DataCell(Text(attempt['AttemptDate'] ?? '')),
                    //     ]);
                    //   }).toList(),
                    // ),
                    // Add more sections as needed
                  ],
                ),
              ),
            ),
    );
  }
}

// Add this class outside of your _InsightsPageState class
class Indicator extends StatefulWidget {
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
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: widget.isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: widget.color,
            ),
          ),
          SizedBox(width: 4),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              color: widget.textColor,
            ),
          )
        ],
      ),
    );
  }
}
