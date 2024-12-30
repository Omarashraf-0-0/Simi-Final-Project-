import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Courses extends StatefulWidget {
  const Courses({Key? key}) : super(key: key);

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  // List to store selected courses
  List<String> selectedCourses = [];

  // Branding colors
  final Color blue1 = const Color(0xFF1c74bb);
  final Color blue2 = const Color(0xFF165d96);
  final Color cyan1 = const Color(0xFF18bebc);
  final Color cyan2 = const Color(0xFF139896);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  // Function to handle the course selection toggle
  void _toggleCourseSelection(String course) {
    setState(() {
      if (selectedCourses.contains(course)) {
        selectedCourses.remove(course); // Remove if already selected
      } else {
        selectedCourses.add(course); // Add if not selected
      }
    });
  }

  // Function to handle API request to register courses
  Future<void> _registerCourses() async {
    var userBox = Hive.box('userBox');
    String? username = userBox.get('username');
    if (username == null) {
      // If username is not found, show an error
      _showErrorDialog('No username found. Please log in.');
      return;
    }

    // Make an API call to register courses with the username
    try {
      final response = await registerCoursesApi(username, selectedCourses);
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == 'Courses registered successfully') {
          // Show success dialog
          _showSuccessDialog('Courses registered successfully.');
        } else {
          throw Exception(responseData['error']);
        }
      } else {
        // Show error dialog
        _showErrorDialog('Failed to register courses. Please try again.');
      }
    } catch (e) {
      // Show error dialog
      _showErrorDialog('Failed to register courses: $e');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error', style: TextStyle(color: black)),
        content: Text(message, style: TextStyle(color: black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: blue2)),
          ),
        ],
      ),
    );
  }

  // Function to show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Success', style: TextStyle(color: black)),
        content: Text(message, style: TextStyle(color: black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Navigate back after success
            },
            child: Text('OK', style: TextStyle(color: blue2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive design
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: blue2,
        title: Text(
          'Courses',
          style: GoogleFonts.leagueSpartan(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
        child: ListView(
          children: [
            // Terms and Courses
            _buildTermDropdown('Term 1', [
              'Computing',
              'Calculus 1',
              'ESP 1',
              'IS',
              'Business',
              'Biochemistry',
              'Physics',
              'Creativity'
            ]),
            // Term 2
            _buildTermDropdown('Term 2', [
              'Problem Solving',
              'Calculus 2',
              'ESP 2',
              'Discrete Mathematics',
              'Entrepreneurship',
              'Advanced Physics',
            ]),
            // Term 3
            _buildTermDropdown('Term 3', [
              'Digital Logic Design',
              'Database Systems',
              'Networks',
              'OOP',
              'Probability and Statistics',
              'Linear Algebra',
            ]),
            // Term 4
            _buildTermDropdown('Term 4', [
              'Computer Architecture',
              'Intro Cyber Security',
              'Software Engineering',
              'Data Structures',
              'Web Development',
              'Advanced OOP',
            ]),
            // Term 5
            _buildTermDropdown('Term 5', [
              'Software Requirements and Specifications',
              'Mobile App Development Training',
              'Intro to Artificial Intelligence',
              'Differential Equations',
              'Project Management',
              'Operating Systems',
              'Theory of Computing',
              'System Programming'
            ]),
            // Term 6
            _buildTermDropdown('Term 6', [
              'Advanced Algorithms',
              'Natural Language Processing',
              'Big Data',
              'Blockchain',
              'Computer Vision',
            ]),
            // Term 7
            _buildTermDropdown('Term 7', [
              'Advanced Operating Systems',
              'Parallel Computing',
              'Cryptography',
              'Network Security',
              'Game Development',
            ]),
            // Term 8
            _buildTermDropdown('Term 8', [
              'Software Testing',
              'Distributed Systems',
              'Computer Networks 2',
              'IoT',
              'Cloud Architecture',
            ]),

            SizedBox(height: size.height * 0.02),

            // Submit Button
            if (selectedCourses.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerCourses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue2,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add Courses',
                    style: GoogleFonts.leagueSpartan(
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

  Widget _buildTermDropdown(String term, List<String> subjects) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: cyan1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.menu_book_outlined, color: Colors.black), // Icon
              const SizedBox(width: 15),
              Text(
                term,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
            ],
          ),
          children: subjects
              .map(
                (subject) => ListTile(
                  leading: Icon(
                    selectedCourses.contains(subject)
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: selectedCourses.contains(subject) ? blue2 : Colors.grey,
                  ),
                  title: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 16,
                      color: black,
                    ),
                  ),
                  onTap: () {
                    _toggleCourseSelection(subject); // Toggle selection
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // API function to register courses
  Future<http.Response> registerCoursesApi(String username, List<String> selectedCourses) async {
    final url = 'https://alyibrahim.pythonanywhere.com/register_courses'; // URL for your Flask API

    final Map<String, dynamic> requestBody = {
      'username': username,
      'Courses': selectedCourses, // Send the list of selected courses
    };

    print("Request body: $requestBody");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }
}