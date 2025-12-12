import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../Classes/User.dart';
import '../Pop-ups/StylishPopup.dart';
import '../util/semantics_keys.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../services/xp_tracker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Add a boolean to manage the "Remember Me" toggle state
  bool isRememberMeChecked = false;

  // Add a boolean to manage the password visibility
  bool isPasswordVisible = false;

  Future<void> awardDailyLoginXP() async {
    final xpTracker = XPTracker();
    await xpTracker.addXP(
      XPTracker.xpDailyLogin,
      reason: 'Daily Login Bonus! 🎉',
      context: context,
    );
  }

  Future<bool> fetchAndSaveProfileImage() async {
    final url =
        'https://alyibrahim.pythonanywhere.com/get-profile-image'; // Replace with your server URL

    try {
      // Get the username from Hive box
      final username = Hive.box('userBox').get('username');
      if (username == null) {
        print("Username not found in Hive box");
        return false;
      }

      // Create a map with the username
      final Map<String, String> body = {
        'username': username,
      };

      // Send the username as JSON in the body of a POST request
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json'
            }, // Set content type to JSON
            body: jsonEncode(body), // Encode the body as JSON
          )
          .timeout(
            Duration(seconds: 30), // Adjust the duration as needed
          );

      if (response.statusCode == 200) {
        // Get the image bytes from the response
        final bytes = response.bodyBytes;

        // Encode the image bytes as Base64
        final base64Image = base64Encode(bytes);

        // Save the Base64 image string to Hive
        Hive.box('userBox').put('profileImageBase64', base64Image);

        // Update the UI to display the image
        return true;
      } else {
        // Handle error if the image is not found or another error occurs
        print(
            "Failed to load image: ${response.statusCode} ===== ${response.body}");
        return false;
      }
    } on TimeoutException catch (_) {
      print("Request timed out");
      return false;
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }

  Future<void> login() async {
    final username = usernameController.text;
    final password = passwordController.text;
    const url =
        'https://alyibrahim.pythonanywhere.com/login'; // Replace with your actual Flask server URL

    try {
      // Ensure the username and password are not empty
      if (username.isEmpty || password.isEmpty) {
        await StylishPopup.warning(
          context: context,
          title: 'Missing Information',
          message: 'Username and password can\'t be empty',
        );
        return;
      }
      // Sending login request with username and password as query parameters
      final Map<String, dynamic> requestBody = {
        'Query': 'login',
        'username': username,
        'password': password,
      };
      // Send the POST request with the JSON body
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(response.body);
      // Parse the JSON response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Save user data to Hive
          Hive.box('userBox').put('id', jsonResponse['id']);
          Hive.box('userBox').put('username', jsonResponse['username']);
          Hive.box('userBox').put('password', jsonResponse['password']);
          Hive.box('userBox').put('fullName', jsonResponse['name']);
          Hive.box('userBox').put('role', jsonResponse['role']);
          Hive.box('userBox').put('email', jsonResponse['email']);
          Hive.box('userBox').put('phone_number', jsonResponse['phone_number']);
          Hive.box('userBox').put('address', jsonResponse['address']);
          Hive.box('userBox').put('gender', jsonResponse['gender']);
          Hive.box('userBox').put('college', jsonResponse['college']);
          Hive.box('userBox').put('university', jsonResponse['university']);
          Hive.box('userBox').put('major', jsonResponse['major']);
          Hive.box('userBox').put('term_level', jsonResponse['term_level']);
          Hive.box('userBox').put('pfp', jsonResponse['pfp']);
          Hive.box('userBox').put('xp', jsonResponse['xp']);
          Hive.box('userBox').put('level', jsonResponse['level']);
          Hive.box('userBox').put('title', jsonResponse['title']);
          Hive.box('userBox')
              .put('Registration_Number', jsonResponse['registrationNumber']);
          Hive.box('userBox').put('birthDate', jsonResponse['birthDate']);
          Hive.box('userBox').put('day_streak', jsonResponse['day_streak']);
          Hive.box('userBox').put('max_streak', jsonResponse['max_streak']);
          Hive.box('userBox').put('last_login', jsonResponse['last_login']);

          fetchAndSaveProfileImage();
          if (isRememberMeChecked) {
            // Save the login state to Hive
            Hive.box('userBox').put('isLoggedIn', true);
            Hive.box('userBox')
                .put('loginTime', DateTime.now().millisecondsSinceEpoch);
          } else {
            // Clear the login state from Hive
            Hive.box('userBox').put('isLoggedIn', false);
          }
          if (jsonResponse['get_xp'] == true) {
            // Award daily login XP using XPTracker
            await awardDailyLoginXP();
          }

          // User? user = User(
          //   id: jsonResponse['id'],
          //   username: jsonResponse['username'],
          //   password: jsonResponse['password'],
          //   fullName: jsonResponse['name'],
          //   role: jsonResponse['role'],
          //   email: jsonResponse['email'],
          //   phoneNumber: jsonResponse['phone_number'],
          //   address: jsonResponse['address'],
          //   gender: jsonResponse['gender'],
          //   collage: jsonResponse['collage'],
          //   university: jsonResponse['university'],
          //   major: jsonResponse['major'],
          //   term_level: jsonResponse['term_level'],
          //   pfp: jsonResponse['pfp'],
          //   xp: jsonResponse['xp'],
          //   level: jsonResponse['level'],
          //   title: jsonResponse['title'],
          //   registrationNumber: jsonResponse['registrationNumber'],
          //   birthDate: jsonResponse['birthDate'],
          // );
          Student student = Student();

          student.id = jsonResponse['id'];
          student.username = jsonResponse['username'];
          student.password = jsonResponse['password'];
          student.fullName = jsonResponse['name'];
          student.role = jsonResponse['role'];
          student.email = jsonResponse['email'];
          student.phoneNumber = jsonResponse['phone_number'];
          student.address = jsonResponse['address'];
          student.gender = jsonResponse['gender'];
          student.collage = jsonResponse['collage'];
          student.university = jsonResponse['university'];
          student.major = jsonResponse['major'];
          student.term_level = jsonResponse['term_level'];
          student.pfp = jsonResponse['pfp'];
          student.xp = jsonResponse['xp'];
          student.level = jsonResponse['level'];
          student.title = jsonResponse['title'];
          student.registrationNumber = jsonResponse['registrationNumber'];
          student.birthDate = jsonResponse['birthDate'];

          // Show success dialog
          await StylishPopup.success(
            context: context,
            title: 'Woo Hoo! 🎉',
            message:
                'Welcome back, ${jsonResponse['name']}!\nReady to continue learning?',
            confirmText: 'Let\'s Go!',
            onConfirm: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.home);
            },
          );
        } else {
          // Failed login, show error message
          await StylishPopup.error(
            context: context,
            title: 'Login Failed',
            message: jsonResponse['message'],
          );
        }
      } else {
        // Server error
        await StylishPopup.error(
          context: context,
          title: 'Error',
          message: response.reasonPhrase == 'UNAUTHORIZED'
              ? 'Wrong Username Or Password'
              : '${response.reasonPhrase}',
        );
      }
    } catch (error) {
      // Handle network or server unreachable errors
      await StylishPopup.error(
        context: context,
        title: 'Network Error',
        message: 'Failed to connect to server\n$error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1c74bb), // Primary Blue
              Color(0xFF165d96), // Primary Blue Dark
              Color(0xFF18bebc), // Primary Cyan
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.4,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.04),

                        // Logo with elegant design
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 40,
                                offset: Offset(0, 20),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: -5,
                                offset: Offset(-10, -10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF18bebc).withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.025),

                        // Welcome Text
                        Text(
                          'Nawart ya Mate',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // White container for form
                        Container(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Semantics(
                                label: SemanticsKeys.loginUsernameField,
                                textField: true,
                                child: TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontFamily: 'Poppins',
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Color(0xFF1c74bb),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1c74bb),
                                            Color(0xFF18bebc),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color(0xFF1c74bb),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              // Password TextField
                              Semantics(
                                label: SemanticsKeys.loginPasswordField,
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: !isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontFamily: 'Poppins',
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Color(0xFF1c74bb),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1c74bb),
                                            Color(0xFF18bebc),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    suffixIcon: Semantics(
                                      label: SemanticsKeys
                                          .loginPasswordVisibilityToggle,
                                      child: IconButton(
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color(0xFF1c74bb),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              // Remember Me and Forgot Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isRememberMeChecked =
                                            !isRememberMeChecked;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Semantics(
                                          label: SemanticsKeys
                                              .loginRememberMeCheckbox,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              gradient: isRememberMeChecked
                                                  ? LinearGradient(
                                                      colors: [
                                                        Color(0xFF1c74bb),
                                                        Color(0xFF18bebc),
                                                      ],
                                                    )
                                                  : null,
                                              color: isRememberMeChecked
                                                  ? null
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: isRememberMeChecked
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Remember Me',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label:
                                        SemanticsKeys.loginForgotPasswordButton,
                                    child: InkWell(
                                      onTap: () => context
                                          .push(AppRoutes.forgotPassword),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Color(0xFF1c74bb),
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 30),

                              // Login Button
                              Semantics(
                                label: SemanticsKeys.loginButton,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1c74bb),
                                        Color(0xFF165d96),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF1c74bb).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Create Account Button
                        Semantics(
                          label: SemanticsKeys.loginRegisterButton,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: OutlinedButton(
                              onPressed: () => context.push(AppRoutes.register),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Create an Account',
                                style: TextStyle(
                                  color: Color(0xFF1c74bb),
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
