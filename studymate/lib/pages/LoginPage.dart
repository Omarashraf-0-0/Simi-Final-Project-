// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import '../Classes/User.dart';
import '../Pop-ups/SuccesPopUp.dart';
import '../util/TextField.dart';
import 'Forget_Pass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'HomePage.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsernameController = TextEditingController();
  final PasswordController = TextEditingController();
  
  // Add a boolean to manage the "Remember Me" toggle state
  bool isRememberMeChecked = false;

  Future<void> login() async {
    final username = UsernameController.text;
    final password = PasswordController.text;
    
    const url = 'https://alyibrahim.pythonanywhere.com/api';  // Replace with your actual Flask server URL

    try {
      // Ensure the username and password are not empty
      if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and password cannot be empty')),
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


      
      // Parse the JSON response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Successful login, show welcome message and navigate
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(jsonResponse['message'])),
          // );
          // navigate to the homepage
          // Inside your login success function
          if (isRememberMeChecked) {
            // Save the username and password to Hive
            Hive.box('userBox').put('isLoggedIn', true);
            Hive.box('userBox').put('loginTime', DateTime.now().millisecondsSinceEpoch);
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
            Hive.box('userBox').put('Registration_Number', jsonResponse['registrationNumber']);
            Hive.box('userBox').put('birthDate', jsonResponse['birthDate']);
          } else {
            // Clear the username and password from Hive
            Hive.box('userBox').put('isLoggedIn', false);

          }
          
          User? user = User(
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
          // Navigate to the homepage
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Homepage(
          //     user: user,
          //   )),
          // );
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DonePopUp(
              user: user,
              title: 'Woo Hoo!',
              description: 'Welcome back, ${jsonResponse['name']}!',
              color : const Color(0xff3BBD5E),
              textColor : Colors.black,
              routeName : '/HomePage',
              )),);
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
        } else {
          // Failed login, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Server error
        showDialog(
          context: context,
          builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Network Error'),
            content: 
            SelectableText(
              'Network error: ${response.statusCode} ${response.headers}'
              ),
            actions: [
            TextButton(
              onPressed: () {
              Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            ],
          );
        },
      );
      }
    } catch (error) {
      // Handle network or server unreachable errors
      showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Network Error'),
        content: SelectableText('Network error: $error'),
        actions: [
        TextButton(
          onPressed: () {
          Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
        ],
      );
      },
    );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              SizedBox(height: 70),
              Image.asset(
                'lib/assets/img/El_Batal_Study_Mate_Light_Mode-removebg-preview.png',
                height: 200,
                width: 500,
              ),
              // Title
              SizedBox(height: 0),
              Text(
                'Nawart ya Mate',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              // Username
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Textfield(
                  controller: UsernameController,
                  hintText: 'Username',
                  suffixIcon: Icon(Icons.person_2_outlined , size: 25,),
                ),
              ),
              // Password
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Textfield(
                  controller: PasswordController,
                  hintText: 'Password',
                  obscureText: true,
                  suffixIcon: Icon(Icons.remove_red_eye,size: 25,),
                  toggleVisability: false,
                ),
              ),
              // Remember Me and Forgot Password
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // "Remember Me" checkbox
                          Checkbox(
                            value: isRememberMeChecked,
                            onChanged: (value) {
                              setState(() {
                                isRememberMeChecked = value!;
                              });
                            },
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(width: 60),
                    InkWell(
                      onTap: () {
                        // Navigate to Forgot Password page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgetPass(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 190, 61, 61),
                          decoration: TextDecoration.underline,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Login Button
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Login button action
                      login();
                      
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Sign up
              SizedBox(height: 60),
              Text(
                "Don't have account?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              // Sign up button
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 93, 150, 1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/RegisterPage');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Etfadal Ma3anaa',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 15,
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
