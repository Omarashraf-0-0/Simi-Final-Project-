import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_constants.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  bool _isImageLoading = true;
  bool isLoading = true; // For courses loading
  bool _isDataLoading = true; // Overall loading state

  late String _fullName;
  late String _title;
  late int _xp;
  late String _email;
  late String _phoneNumber;
  late String _registrationNumber;
  late String _university;
  late String _college;
  late String _major;
  late String _termLevel;
  late int _dayStreak = 0;
  List<String> _courses = [];
  List<String> coursesIndex = [];
  bool isError = false; // To track if an error occurred

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAndSaveProfileImage();
    fetchCourses();
  }

  @override
  void dispose() {
    // Clean up any resources before the widget is disposed
    super.dispose();
  }

  Future<void> fetchCourses() async {
    if (!mounted) return; // Check if the widget is still mounted
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _courses = jsonResponse['courses'].cast<String>();
            coursesIndex = (jsonResponse['CourseID'] as List)
                .map((item) => item['COId'].toString())
                .toList();
            isLoading = false;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        if (mounted) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      }
    } catch (error) {
      print('An error occurred: $error');
      if (!mounted) return;
      if (mounted) {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
      _showErrorDialog(
          'An error occurred. Please check your connection and try again.');
    } finally {
      _checkIfDataLoadingComplete();
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Ensure the widget is still mounted

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error", style: AppConstants.subtitle),
          content: Text(message, style: AppConstants.bodyText),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  fetchCourses(); // Retry fetching courses
                }
              },
              child: Text("Retry",
                  style: TextStyle(color: AppConstants.primaryBlueDark)),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text("Cancel",
                  style: TextStyle(color: AppConstants.primaryBlueDark)),
            ),
          ],
        );
      },
    );
  }

  void _loadUserData() {
    final userBox = Hive.box('userBox');
    _fullName = userBox.get('fullName') ?? '';
    _title = userBox.get('title') ?? 'NewComer';
    _xp = userBox.get('xp') ?? 0;
    _email = userBox.get('email') ?? '';
    _phoneNumber = userBox.get('phone_number') ?? '';
    _registrationNumber = userBox.get('Registration_Number') ?? '';
    _university = userBox.get('university') ?? '';
    _college = userBox.get('college') ?? '';
    _major = userBox.get('major') ?? '';
    _termLevel = '${userBox.get('term_level') ?? ''}';
    _dayStreak = userBox.get('day_streak') ?? 0;
  }

  Future<void> _fetchAndSaveProfileImage() async {
    if (!mounted) return;
    setState(() {
      _isImageLoading = true;
    });

    final url = 'https://alyibrahim.pythonanywhere.com/get-profile-image';
    final username = Hive.box('userBox').get('username');

    final Map<String, String> body = {
      'username': username,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final base64Image = base64Encode(bytes);
        Hive.box('userBox').put('profileImageBase64', base64Image);
      } else {
        print(
            "Failed to load image: ${response.statusCode} ===== ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
      _checkIfDataLoadingComplete();
    }
  }

  void _checkIfDataLoadingComplete() {
    if (!_isImageLoading && !isLoading) {
      if (!mounted) return;
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'El Batal':
        return const Color(0xFFb3141c);
      case 'Legend':
        return const Color(0xFFFFD700);
      case 'Mentor':
        return const Color(0xFF6F42C1);
      case 'Expert':
        return const Color(0xFFFD7E14);
      case 'Challenger':
        return const Color(0xFFFFC107);
      case 'Achiever':
        return const Color(0xFF28A745);
      case 'Explorer':
        return const Color(0xFF007BFF);
      case 'NewComer':
        return const Color(0xFF808080);
      default:
        return Colors.black;
    }
  }

  double _getProgressValue(int xp, String rank) {
    switch (rank) {
      case 'El Batal':
        return (xp - 3000) / 1000;
      case 'Legend':
        return (xp - 2200) / 800;
      case 'Mentor':
        return (xp - 1500) / 700;
      case 'Expert':
        return (xp - 1000) / 500;
      case 'Challenger':
        return (xp - 600) / 400;
      case 'Achiever':
        return (xp - 300) / 300;
      case 'Explorer':
        return (xp - 100) / 200;
      case 'NewComer':
        return xp / 100;
      default:
        return 0.0;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadAndSaveImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadAndSaveImage(File imageFile) async {
    final serverUrl = 'https://alyibrahim.pythonanywhere.com/upload-image';
    final username = Hive.box('userBox').get('username');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      request.fields['username'] = username;

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully!');
        var responseBody = await response.stream.bytesToString();
        print('Server Response: $responseBody');
        _saveProfileImageToHive(imageFile);
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        print('Response: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _saveProfileImageToHive(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      await Hive.box('userBox').put('profileImageBase64', base64String);
      print('Profile image saved successfully!');
      if (!mounted) return;
      setState(() {}); // Refresh the UI
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Widget _buildModernStatCard(
      String value, String label, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: gradientColors[1],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, IconData titleIcon, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryBlue.withOpacity(0.2),
                          AppConstants.primaryCyan.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      titleIcon,
                      color: AppConstants.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF165d96),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items
                .map((item) => _buildModernInfoRow(
                      item['label'] as String,
                      item['value'] as String,
                      item['icon'] as IconData,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryCyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF165d96),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryBlue.withOpacity(0.2),
                          AppConstants.primaryCyan.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: AppConstants.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Courses (${_courses.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF165d96),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isError)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load courses',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_courses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No courses yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  const Divider(height: 1),
                  ..._courses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final course = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: index < _courses.length - 1
                              ? BorderSide(color: Colors.grey[100]!, width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.primaryCyan,
                                  AppConstants.primaryBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              course,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF165d96),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
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
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppConstants.primaryBlueDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isDataLoading
          ? _buildShimmerContent(size)
          : Stack(
              children: [
                // Enhanced Background with gradient and pattern
                Container(
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF5F7FA),
                        const Color(0xFFE8EFF5),
                        const Color(0xFFD6E9F5),
                      ],
                    ),
                  ),
                ),

                // Top gradient header with mesh effect
                Container(
                  height: size.height * 0.38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConstants.primaryBlue,
                        AppConstants.primaryBlueDark,
                        AppConstants.primaryCyan,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: -80,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.12),

                      // Profile Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),

                              // Profile Picture with Rank Badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Profile Picture
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          _getRankColor(_title),
                                          _getRankColor(_title)
                                              .withOpacity(0.6),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getRankColor(_title)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 62,
                                        backgroundImage: Hive.box('userBox')
                                                    .get(
                                                        'profileImageBase64') !=
                                                null
                                            ? MemoryImage(base64Decode(
                                                Hive.box('userBox')
                                                    .get('profileImageBase64')))
                                            : const AssetImage(
                                                    'assets/img/default.jpeg')
                                                as ImageProvider,
                                      ),
                                    ),
                                  ),

                                  // Camera Button
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppConstants.primaryCyan,
                                              AppConstants.primaryCyanDark,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppConstants.primaryCyan
                                                  .withOpacity(0.4),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Name
                              Text(
                                _fullName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF165d96),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // Rank Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getRankColor(_title).withOpacity(0.2),
                                      _getRankColor(_title).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        _getRankColor(_title).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.military_tech_rounded,
                                      color: _getRankColor(_title),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _getRankColor(_title),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Progress Bar
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progress to Next Rank',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          '${(_getProgressValue(_xp, _title) * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _getRankColor(_title),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: _getProgressValue(_xp, _title),
                                        minHeight: 12,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation(
                                          _getRankColor(_title),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModernStatCard(
                                '$_dayStreak',
                                'Day Streak',
                                Icons.local_fire_department_rounded,
                                [Colors.orange[400]!, Colors.deepOrange[600]!],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernStatCard(
                                '$_xp',
                                'Total XP',
                                Icons.stars_rounded,
                                [Colors.amber[400]!, Colors.orange[600]!],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernStatCard(
                                '${_courses.length}',
                                'Courses',
                                Icons.school_rounded,
                                [
                                  AppConstants.primaryCyan,
                                  AppConstants.primaryBlue
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Personal Information Card
                      _buildInfoCard(
                        'Personal Information',
                        Icons.person_rounded,
                        [
                          {
                            'label': 'Email',
                            'value': _email,
                            'icon': Icons.email_rounded
                          },
                          {
                            'label': 'Phone',
                            'value': _phoneNumber,
                            'icon': Icons.phone_rounded
                          },
                          {
                            'label': 'Registration',
                            'value': _registrationNumber,
                            'icon': Icons.badge_rounded
                          },
                        ],
                      ),

                      const SizedBox(height: 15),

                      // College Information Card
                      _buildInfoCard(
                        'College Information',
                        Icons.school_rounded,
                        [
                          {
                            'label': 'University',
                            'value': _university,
                            'icon': Icons.account_balance_rounded
                          },
                          {
                            'label': 'College',
                            'value': _college,
                            'icon': Icons.business_rounded
                          },
                          {
                            'label': 'Major',
                            'value': _major,
                            'icon': Icons.auto_stories_rounded
                          },
                          {
                            'label': 'Term Level',
                            'value': _termLevel,
                            'icon': Icons.stairs_rounded
                          },
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Courses Card
                      _buildCoursesCard(),

                      const SizedBox(height: 20),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red[400]!,
                                Colors.red[600]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                Box userBox = Hive.box('userBox');
                                await userBox.clear();
                                if (mounted) {
                                  context.go(AppRoutes.login);
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmerContent(Size size) {
    return Stack(
      children: [
        // Background gradient (same as main design)
        Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF5F7FA),
                const Color(0xFFE8EFF5),
                const Color(0xFFD6E9F5),
              ],
            ),
          ),
        ),

        // Top gradient header
        Container(
          height: size.height * 0.38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryBlue,
                AppConstants.primaryBlueDark,
                AppConstants.primaryCyan,
              ],
            ),
          ),
        ),

        // Content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.12),

              // Profile Card Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Profile Picture Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: size.width * 0.5,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Rank Badge Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Progress Bar Shimmer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 140,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 40,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Cards Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildShimmerStatCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildShimmerStatCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildShimmerStatCard()),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info Cards Shimmer
              _buildShimmerInfoCard(size),
              const SizedBox(height: 15),
              _buildShimmerInfoCard(size),
              const SizedBox(height: 15),
              _buildShimmerInfoCard(size),

              const SizedBox(height: 20),

              // Logout Button Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerStatCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoCard(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Shimmer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Info Rows Shimmer
            ...List.generate(
                3,
                (index) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: index < 2
                              ? BorderSide(color: Colors.grey[100]!, width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 80,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
