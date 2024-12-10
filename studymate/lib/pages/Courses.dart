import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  // List to store selected courses
  List<String> selectedCourses = [];

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
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No username found. Please log in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Make an API call to register courses with the username
    try {
      final response = await registerCoursesApi(username, selectedCourses);
      print(selectedCourses);
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        print("selectedCkjljourses: $selectedCourses");
        final Map<String, dynamic> Response = jsonDecode(response.body);
        if (Response['success'] == 'Courses registered successfully') {
          // Show success dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Courses registered successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          throw Exception(Response['error']);
        }
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to register courses123.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to register courses: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(color: Colors.black), // Text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              'Software Requirements and specifications',
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
            // Submit Button
            if (selectedCourses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _registerCourses,
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.blue[800]),
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
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border color
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.my_library_books, color: Color.fromARGB(255, 104, 110, 114)), // Icon
              const SizedBox(width: 15),
              Text(
                term,
                style: const TextStyle(fontSize: 18),
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
                    color: selectedCourses.contains(subject)
                        ? Colors.blue[800]
                        : Colors.grey,
                  ),
                  title: Text(subject),
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

  // API function to register coursesc
  Future<http.Response> registerCoursesApi(String username, List<String> selectedCourses) async {
    final url = 'https://alyibrahim.pythonanywhere.com/register_courses';  // URL for your Flask API



    final Map<String, dynamic> requestBody = {
      'username': username,
      'Courses': selectedCourses, // Send the list of selected courses
    };
        print(selectedCourses);

    print("Request bodyiou: $requestBody");
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    return response;
  }
}
