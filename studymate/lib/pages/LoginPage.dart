import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/Pop-ups/PopUps_Failed.dart';
import 'package:studymate/Pop-ups/PopUps_Warning.dart';
import '../Classes/User.dart';
import '../Pop-ups/SuccesPopUp.dart';
import 'Login & Register/Forget_Pass.dart';
import 'package:http/http.dart' as http;
import 'package:studymate/pages/XPChangePopup.dart';
import 'dart:convert';
import 'package:studymate/theme/text_theme.dart';
import 'Login & Register/Register_login.dart';

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

  // Colors according to your branding
  const Color blue1 = Color(0xFF1c74bb);
  const Color blue2 = Color(0xFF165d96);
  const Color cyan1 = Color(0xFF18bebc);
  const Color cyan2 = Color(0xFF139896);
  const Color black = Color(0xFF000000);
  const Color white = Color(0xFFFFFFFF);

  void showXPChangePopup(BuildContext context, int xpChange, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the popup by tapping outside
      builder: (BuildContext context) {
        return XPChangePopup(
          xpChange: xpChange,
          message: message,
        );
      },
    );
  }

  Future<void> updateXpAndTitle(int currentXp) async {
    const xpUrl = 'https://alyibrahim.pythonanywhere.com/set_xp';
    const titleUrl = 'https://alyibrahim.pythonanywhere.com/set_title';
    final username = Hive.box('userBox').get('username');

    int newXp = currentXp + 5; // Add 5 XP

    // Update XP on the server
    final xpResponse = await http.post(
      Uri.parse(xpUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'xp': newXp}),
    );

    if (xpResponse.statusCode == 200) {
      // Update XP locally
      Hive.box('userBox').put('xp', newXp);
      print("XP updated successfully to $newXp");

      // Determine new title based on XP
      String newTitle;
      if (newXp >= 3000) {
        newTitle = 'El Batal';
      } else if (newXp >= 2200) {
        newTitle = 'Legend';
      } else if (newXp >= 1500) {
        newTitle = 'Mentor';
      } else if (newXp >= 1000) {
        newTitle = 'Expert';
      } else if (newXp >= 600) {
        newTitle = 'Challenger';
      } else if (newXp >= 300) {
        newTitle = 'Achiever';
      } else if (newXp >= 100) {
        newTitle = 'Explorer';
      } else {
        newTitle = 'NewComer';
      }

      // Check if the title has changed
      String currentTitle = Hive.box('userBox').get('title');
      if (currentTitle != newTitle) {
        // Update title on the server
        final titleResponse = await http.post(
          Uri.parse(titleUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'title': newTitle}),
        );

        if (titleResponse.statusCode == 200) {
          // Update title locally
          Hive.box('userBox').put('title', newTitle);
          print("Title updated successfully to $newTitle");
        } else {
          print("Failed to update title: ${titleResponse.reasonPhrase}");
        }
      }
    } else {
      print("Failed to update XP: ${xpResponse.reasonPhrase}");
    }
  }

  Future<bool> fetchAndSaveProfileImage() async {
    const url =
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
            const Duration(seconds: 30), // Adjust the duration as needed
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
        showWarningPopup(
          context,
          'Error',
          'Username and password can\'t be empty',
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
            // Get current XP and update the title
            int currentXp =
                jsonResponse['xp'] ?? 0; // Get current XP, default to 0 if null
            await updateXpAndTitle(currentXp);
            showXPChangePopup(context, 5, 'You have gained 5 XP!');
          }

          User? user = User(
            id: jsonResponse['id'],
            username: jsonResponse['username'],
            password: jsonResponse['password'],
            fullName: jsonResponse['name'],
            role: jsonResponse['role'],
            email: jsonResponse['email'],
            phoneNumber: jsonResponse['phone_number'],
            address: jsonResponse['address'],
            gender: jsonResponse['gender'],
            collage: jsonResponse['collage'],
            university: jsonResponse['university'],
            major: jsonResponse['major'],
            term_level: jsonResponse['term_level'],
            pfp: jsonResponse['pfp'],
            xp: jsonResponse['xp'],
            level: jsonResponse['level'],
            title: jsonResponse['title'],
            registrationNumber: jsonResponse['registrationNumber'],
            birthDate: jsonResponse['birthDate'],
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DonePopUp(
                user: user,
                title: 'Woo Hoo!',
                description: 'Welcome back, ${jsonResponse['name']}!',
                color: const Color(0xff3BBD5E),
                textColor: Theme.of(context).colorScheme.secondary,
                routeName: '/HomePage',
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Failed login, show error message
          showWarningPopup(
            context,
            'Error',
            jsonResponse['message'],
          );
        }
      } else {
        // Server error
        showFailedPopup(
          context,
          'Error',
          response.reasonPhrase == 'UNAUTHORIZED'
              ? 'Wrong Username Or Password'
              : '${response.reasonPhrase}',
        );
      }
    } catch (error) {
      // Handle network or server unreachable errors
      showWarningPopup(
        context,
        'Network Error',
        '$error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                SizedBox(height: size.height * 0.08),
                Image.asset(
                  'lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                  height: size.height * 0.25,
                ),
                SizedBox(height: size.height * 0.02),

                // Welcome Text
                Text(
                  'Nawart ya Mate',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 40,
                        fontFamily: 'Poppins',
                      ),
                ),

                // Username TextField
                SizedBox(height: size.height * 0.04),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    floatingLabelStyle: TextStyle(color: theme.primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),

                // Password TextField
                SizedBox(height: size.height * 0.025),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    floatingLabelStyle: TextStyle(color: theme.primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                ),

                // Remember Me and Forgot Password Row
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isRememberMeChecked,
                          activeColor: cyan1,
                          onChanged: (value) {
                            setState(() {
                              isRememberMeChecked = value!;
                            });
                          },
                        ),
                        Text(
                          'Remember Me',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontFamily: 'Poppins',
                                  ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgetPass(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.redAccent,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),

                // Login Button
                SizedBox(height: size.height * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue2,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Sign Up Section
                SizedBox(height: size.height * 0.06),
                Text(
                  "Don't have an account?",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                      ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterLogin(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blue2, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(
                        color: blue2,
                        fontFamily: 'Poppins',
                        fontSize: 18,
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
    );
  }
}
