import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/theme/app_constants.dart';
import '../../Pop-ups/StylishPopup.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> with SingleTickerProviderStateMixin {
  // List to store selected courses
  List<String> selectedCourses = [];
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Brand colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    StylishPopup.error(
      context: context,
      title: 'Error',
      message: message,
      confirmText: 'OK',
    );
  }

  // Function to show success dialog
  void _showSuccessDialog(String message) {
    StylishPopup.success(
      context: context,
      title: 'Success!',
      message: message,
      confirmText: 'Done',
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor, accentColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.library_books_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All Courses',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Choose your subjects',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Selection Count and Search Bar
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedCourses.isEmpty
                                ? Colors.grey.withOpacity(0.2)
                                : primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            selectedCourses.isEmpty
                                ? Icons.check_circle_outline_rounded
                                : Icons.check_circle_rounded,
                            color: selectedCourses.isEmpty
                                ? Colors.grey[600]
                                : primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCourses.isEmpty
                                    ? 'No courses selected'
                                    : '${selectedCourses.length} course${selectedCourses.length != 1 ? 's' : ''} selected',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedCourses.isEmpty
                                    ? 'Tap courses below to add them'
                                    : 'Tap again to remove',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search courses...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          prefixIcon:
                              Icon(Icons.search_rounded, color: primaryColor),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Courses List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildModernTermDropdown(
                    'Term 1',
                    [
                      'Computing',
                      'Calculus 1',
                      'ESP 1',
                      'IS',
                      'Business',
                      'Biochemistry',
                      'Physics',
                      'Creativity'
                    ],
                    Icons.looks_one_rounded,
                    const Color(0xFF1c74bb)),
                _buildModernTermDropdown(
                    'Term 2',
                    [
                      'Problem Solving',
                      'Calculus 2',
                      'ESP 2',
                      'Discrete Mathematics',
                      'Entrepreneurship',
                      'Advanced Physics',
                    ],
                    Icons.looks_two_rounded,
                    const Color(0xFF18bebc)),
                _buildModernTermDropdown(
                    'Term 3',
                    [
                      'Digital Logic Design',
                      'Database Systems',
                      'Networks',
                      'OOP',
                      'Probability and Statistics',
                      'Linear Algebra',
                    ],
                    Icons.looks_3_rounded,
                    const Color(0xFF667eea)),
                _buildModernTermDropdown(
                    'Term 4',
                    [
                      'Computer Architecture',
                      'Intro Cyber Security',
                      'Software Engineering',
                      'Data Structures',
                      'Web Development',
                      'Advanced OOP',
                    ],
                    Icons.looks_4_rounded,
                    const Color(0xFFf093fb)),
                _buildModernTermDropdown(
                    'Term 5',
                    [
                      'Software Requirements and Specifications',
                      'Mobile App Development Training',
                      'Intro to Artificial Intelligence',
                      'Differential Equations',
                      'Project Management',
                      'Operating Systems',
                      'Theory of Computing',
                      'System Programming'
                    ],
                    Icons.looks_5_rounded,
                    const Color(0xFF4facfe)),
                _buildModernTermDropdown(
                    'Term 6',
                    [
                      'Advanced Algorithms',
                      'Natural Language Processing',
                      'Big Data',
                      'Blockchain',
                      'Computer Vision',
                    ],
                    Icons.looks_6_rounded,
                    const Color(0xFF43e97b)),
                _buildModernTermDropdown(
                    'Term 7',
                    [
                      'Advanced Operating Systems',
                      'Parallel Computing',
                      'Cryptography',
                      'Network Security',
                      'Game Development',
                    ],
                    Icons.school_rounded,
                    const Color(0xFFfa709a)),
                _buildModernTermDropdown(
                    'Term 8',
                    [
                      'Software Testing',
                      'Distributed Systems',
                      'Computer Networks 2',
                      'IoT',
                      'Cloud Architecture',
                    ],
                    Icons.workspace_premium_rounded,
                    const Color(0xFF30cfd0)),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      // Floating Action Button for Submit
      floatingActionButton: selectedCourses.isNotEmpty
          ? AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: selectedCourses.isNotEmpty ? 1.0 : 0.0,
              child: Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _registerCourses,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Register ${selectedCourses.length} Course${selectedCourses.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernTermDropdown(
      String term, List<String> subjects, IconData icon, Color color) {
    // Filter subjects based on search query
    final filteredSubjects = searchQuery.isEmpty
        ? subjects
        : subjects.where((s) => s.toLowerCase().contains(searchQuery)).toList();

    if (filteredSubjects.isEmpty) {
      return const SizedBox.shrink();
    }

    // Count selected courses in this term
    final selectedInTerm =
        filteredSubjects.where((s) => selectedCourses.contains(s)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: selectedInTerm > 0
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  Colors.white,
                ],
              )
            : null,
        color: selectedInTerm > 0 ? null : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              selectedInTerm > 0 ? color.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: selectedInTerm > 0
                ? color.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: selectedInTerm > 0
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    )
                  : null,
              color: selectedInTerm > 0 ? null : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              boxShadow: selectedInTerm > 0
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
              icon,
              color: selectedInTerm > 0 ? Colors.white : color,
              size: 26,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  term,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (selectedInTerm > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$selectedInTerm',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${filteredSubjects.length} course${filteredSubjects.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          children: filteredSubjects.asMap().entries.map((entry) {
            final index = entry.key;
            final subject = entry.value;
            final isSelected = selectedCourses.contains(subject);

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.05),
                          ],
                        )
                      : null,
                  color: isSelected ? null : backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _toggleCourseSelection(subject),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Selection Icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [color, color.withOpacity(0.7)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              color:
                                  isSelected ? Colors.white : Colors.grey[400],
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Course Name
                          Expanded(
                            child: Text(
                              subject,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? color : Colors.grey[800],
                              ),
                            ),
                          ),
                          // Selected Badge
                          if (isSelected)
                            AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: isSelected ? 1.0 : 0.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color, color.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Selected',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                ),
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
