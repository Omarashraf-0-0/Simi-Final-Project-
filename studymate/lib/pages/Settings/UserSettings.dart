import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';
import 'package:image_picker/image_picker.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _userUpdater =
      UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  // Colors according to your branding
  final Color blue1 = Color(0xFF1c74bb);
  final Color blue2 = Color(0xFF165d96);
  final Color cyan1 = Color(0xFF18bebc);
  final Color cyan2 = Color(0xFF139896);
  final Color black = Color(0xFF000000);
  final Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with data from Hive
    emailController.text = Hive.box('userBox').get('email', defaultValue: '');
    usernameController.text =
        Hive.box('userBox').get('fullName', defaultValue: '');
  }

  // Method to update user data
  Future<void> updateData() async {
    final Map<String, dynamic> data = {
      'username': Hive.box('userBox').get('username'),
      'fullName': usernameController.text,
      'email': emailController.text,
      'password':
          passwordController.text.isNotEmpty ? passwordController.text : null,
      'confirmPassword': confirmPasswordController.text,
    };

    await _userUpdater.updateUserData(
      requestData: data,
      context: context,
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Perform the upload asynchronously
      await _userUpdater.uploadImageToServer(
        File(pickedFile.path),
        'https://alyibrahim.pythonanywhere.com/upload-image',
        Hive.box('userBox').get('username'),
      );

      // After the async operation completes, update the UI
      setState(() {
        // Refresh the UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the profile image
    final profileImageBase64 = Hive.box('userBox').get('profileImageBase64');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User Settings',
          style: GoogleFonts.leagueSpartan(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Picture',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: cyan1,
                      backgroundImage: profileImageBase64 != null
                          ? MemoryImage(base64Decode(profileImageBase64))
                          : AssetImage('assets/img/default.jpeg')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // User Information Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'User Information',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Username TextField
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              SizedBox(height: 20),
              // Confirm Password TextField
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
              ),
              SizedBox(height: 30),
              // Save Changes Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue2,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
