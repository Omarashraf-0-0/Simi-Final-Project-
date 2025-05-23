import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:studymate/main.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Courses.dart';

class Resources extends StatefulWidget {
  const Resources({super.key});

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  List<String> courses = [];
  List<String> coursesIndex = [];
  bool isLoading = false; // To show a loading indicator
  bool isError = false; // To track if an error occurred

  // Branding colors
  final Color blue1 = const Color(0xFF1c74bb);
  final Color blue2 = const Color(0xFF165d96);
  final Color cyan1 = const Color(0xFF18bebc);
  final Color cyan2 = const Color(0xFF139896);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  void dispose() {
    // Perform any necessary cleanup before the widget is disposed
    super.dispose();
  }

  Future<void> fetchCourses() async {
    // Check if the widget is still mounted before starting
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    const url = 'https://alyibrahim.pythonanywhere.com/TakeCourses';
    final username = Hive.box('userBox').get('username');

    final Map<String, dynamic> requestBody = {
      'username': username,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return; // Check if the widget is still mounted

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("JSON Response: $jsonResponse");
        if(jsonResponse['error'] != null) {
          if (mounted) {
            setState(() {
              isLoading = false;
              courses = [];
            });
          }
          return;
        }
        if (mounted) {
          setState(() {
            courses = jsonResponse['courses'].cast<String>();
            coursesIndex = (jsonResponse['CourseID'] as List)
                .map((item) => item['COId'].toString())
                .toList();
            isLoading = false;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}. Error: ${response.body}');
        if (mounted) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      }
    } catch (error) {
      print('An error occurred: $error');
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        isLoading = false;
        isError = true;
      });
      _showErrorDialog('An error occurred. Please check your connection and try again.');
    }
  }

  String _getCourseBackground(int index) {
    final List<String> backgrounds = [
      'lib/assets/img/bg1.jpg',
      'lib/assets/img/bg2.jpg',
      'lib/assets/img/bg3.jpg',
      'lib/assets/img/bg4.jpg',
      'lib/assets/img/bg5.jpg',
      'lib/assets/img/bg6.jpg',
      'lib/assets/img/bg7.jpg',
      'lib/assets/img/bg8.jpg',
    ];
    return backgrounds[index % backgrounds.length];
  }

  void _showErrorDialog(String message) {
    // Check if the widget is still mounted before showing the dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error", style: TextStyle(color: black)),
          content: Text(message, style: TextStyle(color: black)),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  fetchCourses(); // Retry fetching courses
                }
              },
              child: Text("Retry", style: TextStyle(color: blue2)),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text("Cancel", style: TextStyle(color: blue2)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue2,
        title: Text(
          'Resources',
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: white),
            onPressed: fetchCourses,
          ),
        ],
      ),
      body: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4, // Number of placeholders
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            margin: EdgeInsets.only(bottom: size.height * 0.02),
                            height: size.height * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null, // Disable button during loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'View All Courses',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : isError
              ? Center(
                  child: Text(
                    'An error occurred. Please try again.',
                    style: TextStyle(color: black),
                  ),
                )
              : courses.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No courses assigned yet',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Courses()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blue2,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'View All Courses',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course Cards
                          Expanded(
                            child: ListView.builder(
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                return _buildCourseCard(index);
                              },
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // View All Courses Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => Courses()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue2,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'View All Courses',
                                style: TextStyle(
                                  color: white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildCourseCard(int index) {
    // Screen size for responsive design
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        if (!mounted) return; // Ensure widget is still mounted
        // Handle course card tap
        String title = "Welcome to ${courses[index]}";
        String body = "Get started with the course content";
        // showNotification(title, body);
        Hive.box('userBox').put('COId', coursesIndex[index]);
        print("Course: ${courses[index]}, ${coursesIndex[index]}");
        Navigator.push(context, MaterialPageRoute(builder: (context) => CourseContent()));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.02),
        height: size.height * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(_getCourseBackground(index)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.4),
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courses[index],
                  style: TextStyle(
                    fontSize: 22,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  decoration: BoxDecoration(
                    color: cyan1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'Start',
                    style: TextStyle(
                      color: white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}