import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';

import '../Classes/User.dart';
import '../Pop-ups/SuccesPopUp.dart';
import '../Pop-ups/PopUps_Success.dart';
import '../Pop-ups/PopUps_Failed.dart';
import '../Pop-ups/PopUps_Warning.dart';
import '../util/TextField.dart';
import 'Forget_Pass.dart';
import 'UserUpdater.dart';

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController UsernameController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final TextEditingController ConfirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _userUpdater = UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  // Call this method when updating user data
  Future<void> updateData() async {
    final Map<String, dynamic> data = {
      'username': Hive.box('userBox').get('username'),
      'fullName': UsernameController.text,
      'email': EmailController.text,
      'password': PasswordController.text.isNotEmpty ? PasswordController.text : null,
      'confirmPassword': ConfirmPasswordController.text,
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
        // Trigger a rebuild to update the UI with the new image
        // No additional state variables are needed here if you're relying on Hive to store and retrieve the image data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("The Email : ${Hive.box('userBox').get('id')}");
    EmailController.text = Hive.box('userBox').get('email', defaultValue: 'Default from Hive');
    UsernameController.text = Hive.box('userBox').get('fullName', defaultValue: 'Default from Hive');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF165D96),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Center(child: Text('User Settings')),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          // backgroundColor: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Profile Picture',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.transparent,
                    backgroundImage: Hive.box('userBox').get('profileImageBase64') == null
                        ? null
                        : MemoryImage(base64Decode(Hive.box('userBox').get('profileImageBase64'))),
                    child: Hive.box('userBox').get('profileImageBase64') == null
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01D7ED)),
                    )
                        : null,
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(22, 93, 150, 1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _pickImage();
                        },
                        child: Center(
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // User Information Section
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 55),
              // Username TextField
              SizedBox(
                width: 375,
                child: TextField(
                  controller: UsernameController,
                  decoration: InputDecoration(
                    hintText: 'User',
                    suffixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 55),
              // Email TextField
              SizedBox(
                width: 375,
                child: TextField(
                  controller: EmailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    suffixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 55),
              // Password TextField
              SizedBox(
                width: 375,
                child: TextField(
                  controller: PasswordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_isPasswordVisible,
                ),
              ),
              SizedBox(height: 55),
              // Confirm Password TextField
              SizedBox(
                width: 375,
                child: TextField(
                  controller: ConfirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_isConfirmPasswordVisible,
                ),
              ),
              SizedBox(height: 25),
              // Save Changes Button
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      updateData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                        ),
                      ),
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