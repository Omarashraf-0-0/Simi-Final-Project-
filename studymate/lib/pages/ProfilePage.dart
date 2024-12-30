import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Profilepage extends StatefulWidget {
  const Profilepage({Key? key}) : super(key: key);

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  // Branding colors
  final Color blue1 = const Color(0xFF1c74bb);
  final Color blue2 = const Color(0xFF165d96);
  final Color cyan1 = const Color(0xFF18bebc);
  final Color cyan2 = const Color(0xFF139896);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  bool _isImageLoading = false;
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
  // List<String> _courses = [];
  List<String> _courses = [];
  List<String> coursesIndex = [];
  bool isLoading = false; // To show a loading indicator
  bool isError = false; // To track if an error occurred

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAndSaveProfileImage();
    fetchCourses(); 
  }
    Future<void> fetchCourses() async {
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // print("JSON Response: $jsonResponse");

        setState(() {
          _courses = jsonResponse['courses'].cast<String>();
          coursesIndex = (jsonResponse['CourseID'] as List)
              .map((item) => item['COId'].toString())
              .toList();
          isLoading = false;

        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (error) {
      print('An error occurred: $error');
      setState(() {
        isLoading = false;
        isError = true;
      });
      _showErrorDialog('An error occurred. Please check your connection and try again.');
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error", style: TextStyle(color: black)),
          content: Text(message, style: TextStyle(color: black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                fetchCourses(); // Retry fetching courses
              },
              child: Text("Retry", style: TextStyle(color: blue2)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: blue2)),
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

    // _courses = [];
    // print("This is courses ? $_courses");
  }

  Future<void> _fetchAndSaveProfileImage() async {
    setState(() {
      _isImageLoading = true;
    });

    final url = 'https://alyibrahim.pythonanywhere.com/get-profile-image';
    final username = Hive.box('userBox').get('username');

    final Map<String, String> body = {
      'username': username,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final base64Image = base64Encode(bytes);
        Hive.box('userBox').put('profileImageBase64', base64Image);
      } else {
        print("Failed to load image: ${response.statusCode} ===== ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }

    setState(() {
      _isImageLoading = false;
    });
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
      setState(() {}); // Refresh the UI
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: blue2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.leagueSpartan(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: white),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: _isImageLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture and Name
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: cyan1,
                          backgroundImage: Hive.box('userBox').get('profileImageBase64') != null
                              ? MemoryImage(base64Decode(Hive.box('userBox').get('profileImageBase64')))
                              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: cyan2,
                            child: Icon(
                              Icons.camera_alt,
                              color: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      _fullName,
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      _title,
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(_title),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    // Progress Bar
                    LinearProgressIndicator(
                      value: _getProgressValue(_xp, _title),
                      backgroundColor: Colors.grey[300],
                      color: _getRankColor(_title),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('$_dayStreak', 'Day Streak', Icons.flash_on_outlined, const Color(0xFFE0F6FC), cyan1),
                        _buildStatCard('1', 'Top 5 Finishes', Icons.emoji_events_outlined, const Color(0xFFFDF1CB), const Color(0xFFFDD539)),
                        _buildStatCard('$_xp', 'XP', Icons.star_outline, const Color(0xFFF1D6FC), const Color(0xFFC174FA)), // Changed from 'Gems' to 'XP'
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Personal Information
                    _buildSectionTitle('Personal Information'),
                    _buildInfoRow('Email', _email),
                    _buildInfoRow('Phone Number', _phoneNumber),
                    _buildInfoRow('Registration Number', _registrationNumber),
                    SizedBox(height: size.height * 0.02),
                    // College Information
                    _buildSectionTitle('College Information'),
                    _buildInfoRow('University', _university),
                    _buildInfoRow('College', _college),
                    _buildInfoRow('Major', _major),
                    _buildInfoRow('Term Level', _termLevel),
                    SizedBox(height: size.height * 0.02),
                    // Courses
                    _buildSectionTitle('Courses'),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildCourses(),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Logout Button
                    ElevatedButton(
                      onPressed: () {
                        // Implement logout logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue2,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.leagueSpartan(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.leagueSpartan(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.leagueSpartan(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.leagueSpartan(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cyan1,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _courses.map((course) {
        print(course);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '- $course',
            style: GoogleFonts.leagueSpartan(
              fontSize: 16,
              color: black,
            ),
          ),
        );
      }).toList(),
    );
  }
}