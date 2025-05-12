import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/LoginPage.dart';
import 'package:studymate/pages/Login%20&%20Register/RegisterPage.dart';
import '../../Classes/User.dart';
import '../../Pop-ups/PopUps_Warning.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterLogin extends StatefulWidget {
  const RegisterLogin({super.key});

  @override
  State<RegisterLogin> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<RegisterLogin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? gender;

  // Branding colors
  const Color blue1 = Color(0xFF1c74bb);
  const Color blue2 = Color(0xFF165d96);
  const Color cyan1 = Color(0xFF18bebc);
  const Color cyan2 = Color(0xFF139896);
  const Color black = Color(0xFF000000);
  const Color white = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void dispose() {
    // Dispose controllers to free up resources
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> validateAndProceed() async {

    if (_formKey.currentState!.validate()) {
      if (gender == null) {
        showWarningPopup(context, 'Error', 'Please select your gender.', 'OK');
        return;
      }
      bool isEmailAlreadyUsed = await is_email_already_used(emailController.text);
      if(isEmailAlreadyUsed==true){
        showWarningPopup(context,'Email already used',"The email address \"${emailController.text}\" is already associated with an account. Please use a different email.");
        return ;
      }
      // Create a new User object with the entered data
      User user = User(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        gender: gender,
      );

      // Navigate to the next registration page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(
            user: user,
          ),
        ),
      );
    }
  }

  Future<bool> is_email_already_used(String email) async {
    // Define your backend API endpoint
    const String url = 'https://alyibrahim.pythonanywhere.com/check-email';

    try {
      // Create the HTTP POST request body
      final Map<String, dynamic> requestBody = {'email': email};

      // Send the request to the backend
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check for a successful response
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Assume the backend sends a boolean field `isUsed`
        return responseBody['isUsed'];
      } else {
        throw Exception(
            'Failed to check email. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking email: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Screen size for responsive design
    final size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: blue2),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: size.height * 0.02),
              // Title
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome Aboard!',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        floatingLabelStyle:  TextStyle(color: theme.primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email.';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Invalid email address.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Username Field
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        floatingLabelStyle:  TextStyle(color: theme.primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username.';
                        } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                          return 'Username can only contain letters, numbers, and underscores.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        floatingLabelStyle:  TextStyle(color: theme.primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        } else if (value.length < 8 ||
                            !RegExp(r'[A-Z]').hasMatch(value) ||
                            !RegExp(r'[a-z]').hasMatch(value) ||
                            !RegExp(r'\d').hasMatch(value)) {
                          return 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Confirm Password Field
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        floatingLabelStyle:  TextStyle(color: theme.primaryColor),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        } else if (value != passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Gender Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Gender:',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'Female',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: validateAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue2,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Next',
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
              SizedBox(height: size.height * 0.05),
              // Already have an account
              Center(
                child: Column(
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        // Navigate to Login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: blue2, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 16,
                          color: blue2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}