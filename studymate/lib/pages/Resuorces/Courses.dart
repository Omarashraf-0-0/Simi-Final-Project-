import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/theme/app_constants.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  // List to store selected courses
  List<String> selectedCourses = [];
  String searchQuery = '';
  
  // Brand colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
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

  // Function to show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF43e97b).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF43e97b),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43e97b),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Courses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with Selection Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Your Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedCourses.isEmpty
                      ? 'Tap courses to add them'
                      : '${selectedCourses.length} course${selectedCourses.length != 1 ? 's' : ''} selected',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search courses...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search_rounded),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Courses List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildModernTermDropdown('Term 1', [
                  'Computing',
                  'Calculus 1',
                  'ESP 1',
                  'IS',
                  'Business',
                  'Biochemistry',
                  'Physics',
                  'Creativity'
                ], Icons.looks_one_rounded, const Color(0xFF1c74bb)),
                _buildModernTermDropdown('Term 2', [
                  'Problem Solving',
                  'Calculus 2',
                  'ESP 2',
                  'Discrete Mathematics',
                  'Entrepreneurship',
                  'Advanced Physics',
                ], Icons.looks_two_rounded, const Color(0xFF18bebc)),
                _buildModernTermDropdown('Term 3', [
                  'Digital Logic Design',
                  'Database Systems',
                  'Networks',
                  'OOP',
                  'Probability and Statistics',
                  'Linear Algebra',
                ], Icons.looks_3_rounded, const Color(0xFF667eea)),
                _buildModernTermDropdown('Term 4', [
                  'Computer Architecture',
                  'Intro Cyber Security',
                  'Software Engineering',
                  'Data Structures',
                  'Web Development',
                  'Advanced OOP',
                ], Icons.looks_4_rounded, const Color(0xFFf093fb)),
                _buildModernTermDropdown('Term 5', [
                  'Software Requirements and Specifications',
                  'Mobile App Development Training',
                  'Intro to Artificial Intelligence',
                  'Differential Equations',
                  'Project Management',
                  'Operating Systems',
                  'Theory of Computing',
                  'System Programming'
                ], Icons.looks_5_rounded, const Color(0xFF4facfe)),
                _buildModernTermDropdown('Term 6', [
                  'Advanced Algorithms',
                  'Natural Language Processing',
                  'Big Data',
                  'Blockchain',
                  'Computer Vision',
                ], Icons.looks_6_rounded, const Color(0xFF43e97b)),
                _buildModernTermDropdown('Term 7', [
                  'Advanced Operating Systems',
                  'Parallel Computing',
                  'Cryptography',
                  'Network Security',
                  'Game Development',
                ], Icons.school_rounded, const Color(0xFFfa709a)),
                _buildModernTermDropdown('Term 8', [
                  'Software Testing',
                  'Distributed Systems',
                  'Computer Networks 2',
                  'IoT',
                  'Cloud Architecture',
                ], Icons.workspace_premium_rounded, const Color(0xFF30cfd0)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button for Submit
      floatingActionButton: selectedCourses.isNotEmpty
          ? Container(
              width: size.width * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _registerCourses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Add ${selectedCourses.length} Course${selectedCourses.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernTermDropdown(String term, List<String> subjects, IconData icon, Color color) {
    // Filter subjects based on search query
    final filteredSubjects = searchQuery.isEmpty
        ? subjects
        : subjects.where((s) => s.toLowerCase().contains(searchQuery)).toList();
    
    if (filteredSubjects.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          title: Text(
            term,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            '${filteredSubjects.length} course${filteredSubjects.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          children: filteredSubjects.map((subject) {
            final isSelected = selectedCourses.contains(subject);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isSelected ? Colors.white : Colors.grey[400],
                    size: 24,
                  ),
                ),
                title: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : Colors.grey[800],
                  ),
                ),
                trailing: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Added',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
                onTap: () => _toggleCourseSelection(subject),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // API function to register courses
  Future<http.Response> registerCoursesApi(
      String username, List<String> selectedCourses) async {
    final url =
        'https://alyibrahim.pythonanywhere.com/register_courses'; // URL for your Flask API

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
